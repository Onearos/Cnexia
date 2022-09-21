//
//  FetchImage.swift
//  Cnexia
//
//  Created by Macbook PRO on 21/09/2022.
//

import UIKit

protocol FetchImage {
    func execute(forModel model: Car) -> UIImage?
}

final class FetchImageAdapter: FetchImage {
    func execute(forModel model: Car) -> UIImage? {
        switch model.model {
        case "Range Rover":
            return .init(named: "rangeRover")
        case "Roadster":
            return .init(named: "alpineRoadster")
        case "3300i":
            return .init(named: "bmw330")
        case "GLE coupe":
            return .init(named: "mercedesGLE")
        default:
            return nil
        }
    }
}
