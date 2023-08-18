//
//  ListenToCollectionPublisher.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 5/22/23.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct ListenerOuput<T: Codable> {
    public var data: T
    public var changeType: DocumentChangeType
}

extension Publishers {
    
    struct ListenToCollectionAndChangesPublisher<T: Codable>: Publisher {
        
        typealias Output = [ListenerOuput<T>]
        typealias Failure = Error
        var path: PathToCollection
        var predicates: [FireThelPredicate]
        
        func receive<S>(subscriber: S) where S : Subscriber, Error == S.Failure, [ListenerOuput<T>] == S.Input {
            let subscription = ListenToCollectionChangesSubscription<S, T>(
                subscriber: subscriber,
                path: path,
                predicates: predicates
            )
            subscriber.receive(subscription: subscription)
        }
    }
    
    class ListenToCollectionChangesSubscription<S: Subscriber, T: Codable>: Subscription where S.Input == [ListenerOuput<T>], S.Failure == Error {
        
        private var subscriber: S?
        private var listener: ListenerRegistration?
        private var path: PathToCollection
        private var predicates: [FireThelPredicate]
        
        init(subscriber: S, path: PathToCollection, predicates: [FireThelPredicate]) {
            self.subscriber = subscriber
            self.path = path
            self.predicates = predicates
            
            var refQuery: Query = Firestore.firestore().collection(path)
            
            for predicate in predicates {
                refQuery = refQuery.getQuery(for: predicate)
            }
            
            listener = refQuery.addSnapshotListener { querySnap, error in
                if let err = error {
                    subscriber.receive(completion: .failure(err))
                } else if let query = querySnap {
                    let docs: [ListenerOuput<T>] = query.documentChanges.compactMap {
                        try? .init(data: $0.document.data(as: T.self), changeType: $0.type)
                    }
                    _ = subscriber.receive(docs)
                }
            }
        }
        
        func request(_ demand: Subscribers.Demand) {}
        func cancel() {
            subscriber = nil
            listener = nil
        }
    }
}

