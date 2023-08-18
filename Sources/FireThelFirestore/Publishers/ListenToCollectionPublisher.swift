//
//  File.swift
//  
//
//  Created by Vebjørn Daniloff on 24/05/2023.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

extension Publishers {
    
    struct ListenToCollectionPublisher<T: Codable>: Publisher {
        
        typealias Output = [T]
        typealias Failure = Error
        var path: PathToCollection
        var predicates: [FireThelPredicate]
        
        func receive<S>(subscriber: S) where S : Subscriber, Error == S.Failure, [T] == S.Input {
            let subscription = ListenToCollectionSubscription<S, T>(
                subscriber: subscriber,
                path: path,
                predicates: predicates
            )
            subscriber.receive(subscription: subscription)
        }
    }
    
    class ListenToCollectionSubscription<S: Subscriber, T: Codable>: Subscription where S.Input == [T], S.Failure == Error {
        
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
                    let docs = query.documents.compactMap {
                        try? $0.data(as: T.self)
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
