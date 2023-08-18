//
//  UserPublic.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/11/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Restaurant: Codable, Hashable {
    @DocumentID var id: String?
    var docId: String? { id }
    var name: String
    var type: String
    
    init(name: String, type: RestaurantType) {
        self.name = name
        self.type = type.rawValue
    }
}

extension Restaurant {
    init(name: String, type: String) {
        self.name = name
        self.type = type
    }
}

enum RestaurantType: String, CaseIterable {
    case Indian
    case American
    case Asian
    case Italian
}
