//
//  Menu.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/11/23.
//

import Foundation
import FirebaseFirestoreSwift

struct RestaurantMenu: Codable {
    @DocumentID var id: String?
    var specialDish: String
    var desert: String
}


