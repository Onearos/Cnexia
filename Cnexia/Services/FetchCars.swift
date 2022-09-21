//
//  FetchCars.swift
//  Cnexia
//
//  Created by Macbook PRO on 21/09/2022.
//

import Foundation

protocol FetchCars {
    func fetch(completion: @escaping (Result<[Car], GuidomiaServiceError>) -> Void)
}

final class FetchCarsAdapter {
    var service: GuidomiaService
    var storage: GuidomiaStorage
    
    init(service: GuidomiaService = LocalGuidomiaServiceAdapter(),
         storage: GuidomiaStorage = GuidomiaStorageAdapter(storage: .standard)) {
        self.service = service
        self.storage = storage
    }
}

extension FetchCarsAdapter: FetchCars {
    func fetch(completion: @escaping (Result<[Car], GuidomiaServiceError>) -> Void) {
        let data = storage.getCars()
        
        guard data.isEmpty else {
            completion(.success(data))
            return
        }
        service.fetch { [weak self] response in
            guard case .success(let cars) = response else {
                completion(response)
                return
            }
            
            self?.storage.save(cars: cars)
            completion(response)
        }
    }
}
