//
//  CollectionPath.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/13/23.
//

import Foundation

// MARK: - Factory for Firestore collection path
extension String {
    enum CollectionPath {
        case restaurant
        case menu(restaurantId: String)
    }
    
    // Factory
    static func getPath(for path: CollectionPath) -> String {
        switch path {
        case .restaurant:
            return "restaurant"
        case .menu(let restaurantId):
            return "restaurant/\(restaurantId)/menu"
        }
    }
}
