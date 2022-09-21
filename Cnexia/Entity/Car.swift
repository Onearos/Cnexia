//
//  Car.swift
//  Cnexia
//
//  Created by Macbook PRO on 21/09/2022.
//

import Foundation

struct Car: Codable {
    enum Make: String, Codable {
        case landRover = "Land Rover"
        case alpine = "Alpine"
        case bmw = "BMW"
        case mercedesBenz = "Mercedes Benz"
    }
    
    var consList: [String]
    var customerPrice: Double
    var make: Make
    var marketPrice: Double
    var model: String
    var prosList: [String]
    var rating: Int
}
