//
//  EditViewModel.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/14/23.
//

import Foundation
import FireThelFirestore
import FirebaseFirestore
import Combine

struct EditViewModel {
    private let db = Firestore.firestore()
    
    var stateSubject = PassthroughSubject<State, Never>()
    
    func updateDocument(
        name: String,
        restaurantType: String,
        documentId: String
    ) async {
        guard !name.isEmpty && !restaurantType.isEmpty else {
            stateSubject.send(.error(.defaultCustom("Fields can't be empty")))
            return
        }
        
        stateSubject.send(.loading)
        
        let fields: [AnyHashable: Any] = [
            "name": name,
            "type": restaurantType
        ]
//        let restaurant: Restaurant = .init(name: name, type: restaurantType)
        
        do {
            // this is for demonstration of updateDoc, you can of course use createDoc instead to update it
            try await db.updateDoc(fields, path: .getPath(for: .restaurant), documentId: documentId)
//            try await db.createDoc(model: restaurant, path: .getPath(for: .restaurant), documentId: documentId)
            
            stateSubject.send(.success)
        } catch {
            stateSubject.send(.error(.default(error)))
        }
    }
}

extension EditViewModel {
    enum State {
        case loading
        case success
        case error(CustomError)
    }
}
