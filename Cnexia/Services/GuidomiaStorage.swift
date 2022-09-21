//
//  GuidomiaStorage.swift
//  Cnexia
//
//  Created by Macbook PRO on 21/09/2022.
//

import Foundation

protocol GuidomiaStorage {
    func save(cars: [Car])
    func getCars() -> [Car]
    func delete()
}

final class GuidomiaStorageAdapter: GuidomiaStorage {
    private let key: String = "Cars_Key"
    
    var storage: UserDefaults
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
    }
    
    func save(cars: [Car]) {
        guard let data = try? JSONEncoder().encode(cars) else {
            return
        }
            
        storage.set(data, forKey: key)
    }
    
    func getCars() -> [Car] {
        guard let data = storage.data(forKey: key),
              let cars = try? JSONDecoder().decode([Car].self, from: data) else {
            return []
        }
        
        return cars
    }
    
    func delete() {
        storage.removeObject(forKey: key)
    }
}
