//
//  Firestore+Paths.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/11/23.
//

import Foundation

enum CollectionPath {
    case restaurant
    case menu(restaurantId: String)
}

// Factory
extension String {
    static func getPath(for path: CollectionPath) -> String {
        switch path {
        case .restaurant:
            return "restaurant"
        case .menu(let restaurantId):
            return "restaurant/\(restaurantId)/menu"
        }
    }
}
