//
//  File.swift
//  
//
//  Created by Vebjørn Daniloff on 24/05/2023.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

public typealias PathToDocument = String
public typealias PathToCollection = String

extension Firestore {
    // MARK: - GET
    
    /// Call to get any objects that conforms to Codable.
    ///
    /// - Parameter path: The path to your document. Preferably use create a [factory]( https://github.com/vebbis321/FireThel/tree/createNewDemo#step-2-optional ).
    /// - Returns: An object you specify.
    public func getDoc<T>(
        path: PathToCollection,
        documentId: String
    ) async throws -> T where T : Codable {
        let ref = Firestore.firestore().collection(path).document(documentId)
        
        return try await ref.getDocument(as: T.self)
    }
    
    
    /// Call to get an array of any object that conforms to Codable .
    ///
    /// Will not throw if one of the documents fails retriving, but will throw if the query itself fails.
    ///
    /// - Parameters:
    ///   - path: The path to your collection. Preferably use create a [factory]( https://github.com/vebbis321/FireThel/tree/createNewDemo#step-2-optional ).
    ///   - predicates: To filter the collection. The order of the filters should be equivalent to [Firestore]( https://cloud.google.com/firestore/docs/query-data/queries ).
    /// - Returns: Array of your specified object.
    public func getDocs<T>(
        path: PathToCollection,
        predicates: [FireThelPredicate] = []
    ) async throws -> [T] where T : Codable {
        var refQuery: Query = Firestore.firestore().collection(path)

        for predicate in predicates {
            refQuery = refQuery.getQuery(for: predicate)
        }
      
        let querySnapshot = try await refQuery.getDocuments()

        return querySnapshot.documents.compactMap { doc in
            return try? doc.data(as: T.self)
        }
    }
  
    // MARK: - CREATE
    
    /// Creates any document in Firestore with a custom id, or overwrites current if it does exist.
    ///
    /// If you don't want to set the id, use addDoc().
    /// - Parameters:
    ///   - model: Any struct that conforms to codable
    ///   - path: The path to the document. Preferably use create a [factory]( https://github.com/vebbis321/FireThel/tree/createNewDemo#step-2-optional ).
    ///   - id: Your custom id for the document.
    public func createDoc(
        model: some Codable,
        path: PathToCollection,
        documentId: String
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            createDoc(model: model, path: path, documentId: documentId) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - ADD
    /// Adds any document in Firestore with a id made by Firestore.
    ///
    /// - Parameters:
    ///   - path: The path to the document. Preferably use create a [factory]( https://github.com/vebbis321/FireThel/tree/createNewDemo#step-2-optional ).
    @discardableResult
    public func addDoc(
        model: some Codable,
        path: PathToCollection
    ) async throws -> DocumentReference {
        return try await withCheckedThrowingContinuation { continuation in
            addDoc(model: model, path: path) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - UPDATE
    
    /// - Parameters:
    ///   - fields: Which fields to update.
    ///   - path: The path to the document. Preferably use create a [factory]( https://github.com/vebbis321/FireThel/tree/createNewDemo#step-2-optional ).
    public func updateDoc(
        _ fields: [AnyHashable: Any],
        path: PathToCollection,
        documentId: String
    ) async throws {
        let ref = Firestore.firestore().collection(path).document(documentId)
        try await ref.updateData(fields)
    }
    
    // MARK: - DELETE
    public func deleteDoc(
        path: PathToCollection,
        documentId: String
    ) async throws {
        let ref = Firestore.firestore().collection(path).document(documentId)
        try await ref.delete()
    }
    
    // MARK: - OBSERVE (SNAPSHOTLISTENER)
    
    /// Creates a publisher that returns  an array of ``ListenerOuput`` with the object you specify.
    ///
    /// receiveCompletion is required in your pipeline when you subscribe to the publisher since the Output type also contains a error.
    ///
    /// - Parameters:
    ///   - path: The path to your collection. Preferably use create a [factory]( https://github.com/vebbis321/FireThel/tree/createNewDemo#step-2-optional ).
    ///   - predicates: To filter the collection. The order of the filters should be equivalent to [Firestore]( https://cloud.google.com/firestore/docs/query-data/queries ).
    /// - Returns: Returns a publisher with Output of  an array of ``ListenerOuput`` with the object you specify and Failure of ``Error``.
    public func observeCollectionAndChanges<T: Codable>(
        path: PathToCollection,
        predicates: [FireThelPredicate] = []
    ) -> AnyPublisher<[ListenerOuput<T>], Error> {
        return Publishers.ListenToCollectionAndChangesPublisher<T>(
            path: path,
            predicates: predicates
        ).eraseToAnyPublisher()
    }
    
    /// Creates a publisher that returns an array of any documents.
    ///
    /// receiveCompletion is required in your pipeline when you subscribe to the publisher since the Output type also contains a error.
    ///
    /// - Parameters:
    ///   - path: The path to your collection. Preferably use create a [factory]( https://github.com/vebbis321/FireThel/tree/createNewDemo#step-2-optional ).
    ///   - predicates: To filter the collection. The order of the filters should be equivalent to [Firestore]( https://cloud.google.com/firestore/docs/query-data/queries ).
    /// - Returns: Returns a publisher with Output of documents that conforms to ``Codable``  and Failure of ``Error``.
    public func observeCollection<T: Codable>(
        path: PathToCollection,
        predicates: [FireThelPredicate] = []
    ) -> AnyPublisher<[T], Error> {
        return Publishers.ListenToCollectionPublisher(
            path: path,
            predicates: predicates
        ).eraseToAnyPublisher()
    }
}

// MARK: - Completion handlers
private extension Firestore {
    private func createDoc(
        model: some Codable,
        path: PathToCollection,
        documentId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let ref = Firestore.firestore().collection(path).document(documentId)
        do {
            try ref.setData(from: model)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func addDoc(
        model: some Codable,
        path: PathToCollection,
        completion: @escaping (Result<DocumentReference, Error>)->Void
    ) {
        let ref = Firestore.firestore().collection(path)
        do {
            let docRef = try ref.addDocument(from: model)
            completion(.success((docRef)))
        } catch {
            completion(.failure(error))
        }
    }
}
