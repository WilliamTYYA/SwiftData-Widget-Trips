//
//  DataModel+UnreadTrips.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/13/25.
//

import Foundation
import SwiftData

extension DataModel {
    struct UserDefaultsKey {
        static let unreadTripIdentifiers: String = "unreadTripIdentifiers"
        static let historyToken: String = "historyToken"
    }
    
    var unreadTripIdentifiersInUserDefaults: [PersistentIdentifier] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKey.unreadTripIdentifiers) else {
            return []
        }
        let tripIdentifiers = try? JSONDecoder().decode([PersistentIdentifier].self, from: data)
        return tripIdentifiers ?? []
    }
    
    func setUnreadTripIdentifiersInUserDefaults(_ tripIdentifiers: [PersistentIdentifier]) {
        let data = try? JSONEncoder().encode(tripIdentifiers)
        UserDefaults.standard.set(data, forKey: UserDefaultsKey.unreadTripIdentifiers)
    }
    
    func findUnreadTripIdentifiers() -> [PersistentIdentifier] {
        let unreadTrips = unreadTrips()
        return Array(unreadTrips).map { $0.persistentModelID }
    }
    
    private func unreadTrips() -> Set<Trip> {
        let tokenData = UserDefaults.standard.data(forKey: UserDefaultsKey.historyToken)
        
        var historyToken: DefaultHistoryToken? = nil
        if let data = tokenData {
            historyToken = try? JSONDecoder().decode(DefaultHistoryToken.self, from: data)
        }
        
        let transactions = findTransaction(after: historyToken, author: TransactionAuthor.widget)
        let (unreadTrips, newToken) = findTrips(in: transactions)
        
        if let token = newToken {
            let data = try? JSONEncoder().encode(token)
            UserDefaults.standard.set(data, forKey: UserDefaultsKey.historyToken)
        }
        
        return unreadTrips
    }
    
    private func findTransaction(after historyToken: DefaultHistoryToken?, author: String) -> [DefaultHistoryTransaction] {
        var historyDescriptor = HistoryDescriptor<DefaultHistoryTransaction>()
        if let token = historyToken {
            historyDescriptor.predicate = #Predicate { transaction in
                transaction.token > token && transaction.author == author
            }
        }
        
        var transactions: [DefaultHistoryTransaction] = []
        let taskContext = ModelContext(modelContainer)
        
        do {
            transactions = try taskContext.fetchHistory(historyDescriptor)
        } catch {
            print(error)
        }
        
        return transactions
    }
    
    private func findTrips(in transactions: [DefaultHistoryTransaction]) -> (Set<Trip>, DefaultHistoryToken?) {
        let taskContext = ModelContext(modelContainer)
        var trips = Set<Trip>()
        
        for transaction in transactions {
            for change in transaction.changes where isLivingAccommodationChange(change) {
                
                let modelID = change.changedPersistentIdentifier
                let fetchDescriptor = FetchDescriptor<Trip>(predicate: #Predicate {
                    $0.livingAccommodation?.persistentModelID == modelID
                })
                
                if let matchedTrip = try? taskContext.fetch(fetchDescriptor).first {
                    switch change {
                    case .insert:
                        trips.insert(matchedTrip)
                    case .update:
                        trips.update(with: matchedTrip)
                    case .delete:
                        trips.remove(matchedTrip)
                    default:
                        break
                    }
                }
            }
        }
        
        return (trips, transactions.last?.token)
    }
    
    private func isLivingAccommodationChange(_ change: HistoryChange) -> Bool {
        switch change {
        case .insert(let historyInsert):
            if historyInsert is any HistoryInsert<LivingAccommodation> {
                return true
            }
        case .update(let historyUpdate):
            if historyUpdate is any HistoryUpdate<LivingAccommodation> {
                return true
            }
        case .delete(let historyDelete):
            if historyDelete is any HistoryDelete<LivingAccommodation> {
                return true
            }
        default:
            break
        }
        return false
    }
}
