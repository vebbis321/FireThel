//
//  File.swift
//  
//
//  Created by Vebjorn Daniloff on 8/18/23.
//

import FirebaseDatabase
import FirebaseDatabaseSwift
import Combine

public typealias Path = String

extension DatabaseReference {
    // MARK: - CREATE / UPDATE
    public func performAtomicWrites(
        data: [Path: Codable]
    ) async throws {
        let mappedData = try data.mapValues { try $0.dict() }
        try await self.updateChildValues(mappedData)
    }

    public func setData(
        path: String,
        model: some Codable
    ) async throws {
        let ref = self.child(path)
        return try await withCheckedThrowingContinuation({ continuation in
            do {
                try ref.setValue(from: model)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        })
    }

    // MARK: - OBSERVE
    public func observeChildNode<T: Codable>(
        path: Path,
        event: DataEventType
    ) -> AnyPublisher<T, Error> {
        let ref = self.child(path)
        return Publishers.ObserveNodePublisher(ref: ref, event: event).eraseToAnyPublisher()
    }

    public func observeChildNodes<T: Codable>(
        path: Path,
        event: DataEventType
    ) -> AnyPublisher<[T], Error> {
        let ref = self.child(path)
        return Publishers.ObserveChildNodesPublisher(ref: ref, event: event).eraseToAnyPublisher()
    }
}


