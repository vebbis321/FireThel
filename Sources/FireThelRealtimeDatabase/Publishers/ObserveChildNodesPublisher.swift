//
//  File.swift
//  
//
//  Created by Vebjorn Daniloff on 8/18/23.
//

import Foundation
import Combine
import FirebaseDatabase
import FirebaseDatabaseSwift
import Foundation

extension Publishers {
    struct ObserveChildNodesPublisher<T: Codable>: Publisher {
        typealias Output = [T]
        typealias Failure = Error
        var ref: DatabaseReference
        var event: DataEventType

        func receive<S>(subscriber: S) where S: Subscriber, Error == S.Failure, [T] == S.Input {
            let observeNodeSubscription = ObserveChildNodesSubscription(subscriber: subscriber, ref: ref, event: event)
            subscriber.receive(subscription: observeNodeSubscription)
        }
    }

    class ObserveChildNodesSubscription<S: Subscriber, T: Codable>: Subscription where S.Input == [T], S.Failure == Error {
        private var subscriber: S?
        private var ref: DatabaseReference
        private var event: DataEventType

        init(subscriber: S, ref: DatabaseReference, event: DataEventType) {
            self.subscriber = subscriber
            self.event = event
            self.ref = ref

            ref.observe(event) { snapshot, _ in

                if let children = snapshot.children.allObjects as? [DataSnapshot] {
                    let mappedChildren = children.compactMap { snap in
                        return try? snap.data(as: T.self)
                    }
                    _ = subscriber.receive(mappedChildren)
                } else {
                    subscriber.receive(completion: .failure(RealtimeDatabaseError.defaultCustom("Child objects doesn't exist at path.")))
                }
            }
        }

        func request(_: Subscribers.Demand) {}
        func cancel() {
            ref.removeAllObservers()
            subscriber = nil
        }
    }
}
