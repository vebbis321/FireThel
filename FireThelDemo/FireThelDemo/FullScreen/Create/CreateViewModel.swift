//
//  CreateViewModel.swift
//  FireEaseDemo
//
//  Created by Vebjorn Daniloff on 8/11/23.
//

import FireThelFirestore
import FirebaseFirestore
import Combine

struct CreateViewModel {
    private let db = Firestore.firestore()
    
    var stateSubject = PassthroughSubject<State, Never>()
    
    func createDocuments(
        name: String,
        restaurantType: String,
        specialDish: String,
        desert: String
    ) async {
        guard !name.isEmpty && !restaurantType.isEmpty && !specialDish.isEmpty && !desert.isEmpty else {
            stateSubject.send(.error(.defaultCustom("Fields can't be empty")))
            return
        }
        
        stateSubject.send(.loading)
        
        let restaurant = Restaurant(name: name, type: RestaurantType(rawValue: restaurantType)!)
        let menu = RestaurantMenu(specialDish: specialDish, desert: desert)
        
        do {
            // add(), if you want Firebase to take care of the id
            let reference = try await db.addDoc(model: restaurant, path: .getPath(for: .restaurant))
            
            // create(), if you want to update or set a doc with a custom id
            try await db.createDoc(model: menu, path: .getPath(for: .menu(restaurantId: reference.documentID)), documentId: reference.documentID)
            stateSubject.send(.success)
        } catch {
            stateSubject.send(.error(.default(error)))
        }
    }
}

extension CreateViewModel {
    enum State {
        case loading
        case success
        case error(CustomError)
    }
}
