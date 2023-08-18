//
//  File.swift
//  
//
//  Created by Vebjørn Daniloff on 25/05/2023.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

extension Query {
    func getQuery(for predicate: FireThelPredicate) -> Query {
        
        switch predicate {
        case let .isNotEqualTo(field, value):
            return self.whereField(field, isNotEqualTo: value)
        case let .isEqualTo(field, value):
            return self.whereField(field, isEqualTo: value)
        case let .isIn(field, values):
            return self.whereField(field, in: values)
        case let .isNotIn(field, values):
            return self.whereField(field, notIn: values)
        case let .arrayContains(field, value):
            return self.whereField(field, arrayContains: value)
        case let .arrayContainsAny(field, values):
            return self.whereField(field, arrayContainsAny: values)
        case let .isLessThan(field, value):
            return self.whereField(field, isLessThan: value)
        case let .isGreaterThan(field, value):
            return self.whereField(field, isGreaterThan: value)
        case let .isLessThanOrEqualTo(field, value):
            return self.whereField(field, isLessThanOrEqualTo: value)
        case let .isGreaterThanOrEqualTo(field, value):
            return self.whereField(field, isGreaterThanOrEqualTo: value)
        case let .orderBy(field, value):
            return self.order(by: field, descending: value)
        case let .limitTo(field):
            return self.limit(to: field)
        case let .limitToLast(field):
            return self.limit(toLast: field)
        }
    }
}
