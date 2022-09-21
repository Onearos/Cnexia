//
//  GuidomiaService.swift
//  Cnexia
//
//  Created by Macbook PRO on 21/09/2022.
//

import Foundation

enum GuidomiaServiceError: Error {
    case fileNotFound
    case parsingError
}

protocol GuidomiaService {
    func fetch(completion: @escaping (Result<[Car], GuidomiaServiceError>) -> Void)
}

final class LocalGuidomiaServiceAdapter {
    
}

extension LocalGuidomiaServiceAdapter: GuidomiaService {
    func fetch(completion: @escaping (Result<[Car], GuidomiaServiceError>) -> Void) {
        guard let path = Bundle.main.path(forResource: "car_list", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
            completion(.failure(.fileNotFound))
            return
        }
        
        guard let info = try? JSONDecoder().decode([Car].self, from: data) else {
            completion(.failure(.parsingError))
            return
        }
        
        completion(.success(info))
    }
}
