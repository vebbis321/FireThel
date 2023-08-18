//
//  File.swift
//  
//
//  Created by Vebjorn Daniloff on 8/10/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// for missing cases
public enum FireThelPredicate {
    case isEqualTo(_ field: String, _ value: Any)
    
    // TODO: this is missing in QueryPredicate, will note Firebase
    case isNotEqualTo(_ field: String, _ value: Any)
   
    case isIn(_ field: String, _ values: [Any])
    case isNotIn(_ field: String, _ values: [Any])
    
    case arrayContains(_ field: String, _ value: Any)
    case arrayContainsAny(_ field: String, _ values: [Any])
    
    case isLessThan(_ field: String, _ value: Any)
    case isGreaterThan(_ field: String, _ value: Any)
    
    case isLessThanOrEqualTo(_ field: String, _ value: Any)
    case isGreaterThanOrEqualTo(_ field: String, _ value: Any)
    
    case orderBy(_ field: String, _ value: Bool)
    
    case limitTo(_ value: Int)
    case limitToLast(_ value: Int)
    
    /*
     Factory methods
     */
    public static func whereField(_ field: String, isEqualTo value: Any) -> FireThelPredicate {
        .isEqualTo(field, value)
    }
    
    public static func whereField(_ field: String, isNotEqualTo value: Any) -> FireThelPredicate {
        .isNotEqualTo(field, value)
    }
    
    
    public static func whereField(_ field: String, isIn values: [Any]) -> FireThelPredicate {
        .isIn(field, values)
    }
    
    public static func whereField(_ field: String, isNotIn values: [Any]) -> FireThelPredicate {
        .isNotIn(field, values)
    }
    
    public static func whereField(_ field: String, arrayContains value: Any) -> FireThelPredicate {
        .arrayContains(field, value)
    }
    
    public static func whereField(_ field: String,
                                  arrayContainsAny values: [Any]) -> FireThelPredicate {
        .arrayContainsAny(field, values)
    }
    
    public static func whereField(_ field: String, isLessThan value: Any) -> FireThelPredicate {
        .isLessThan(field, value)
    }
    
    public static func whereField(_ field: String, isGreaterThan value: Any) -> FireThelPredicate {
        .isGreaterThan(field, value)
    }
    
    public static func whereField(_ field: String,
                                  isLessThanOrEqualTo value: Any) -> FireThelPredicate {
        .isLessThanOrEqualTo(field, value)
    }
    
    public static func whereField(_ field: String,
                                  isGreaterThanOrEqualTo value: Any) -> FireThelPredicate {
        .isGreaterThanOrEqualTo(field, value)
    }
    
    public static func order(by field: String, descending value: Bool = false) -> FireThelPredicate {
        .orderBy(field, value)
    }
    
    public static func limit(to value: Int) -> FireThelPredicate {
        .limitTo(value)
    }
    
    public static func limit(toLast value: Int) -> FireThelPredicate {
        .limitToLast(value)
    }
    
    // Alternate naming
    
    public static func `where`(_ name: String, isEqualTo value: Any) -> FireThelPredicate {
        .isEqualTo(name, value)
    }
    
    public static func `where`(_ name: String, isNotEqualTo value: Any) -> FireThelPredicate {
        .isNotEqualTo(name, value)
    }
    
    public static func `where`(_ name: String, isIn values: [Any]) -> FireThelPredicate {
        .isIn(name, values)
    }
    
    public static func `where`(_ name: String, isNotIn values: [Any]) -> FireThelPredicate {
        .isNotIn(name, values)
    }
    
    public static func `where`(field name: String, arrayContains value: Any) -> FireThelPredicate {
        .arrayContains(name, value)
    }
    
    public static func `where`(_ name: String, arrayContainsAny values: [Any]) -> FireThelPredicate {
        .arrayContainsAny(name, values)
    }
    
    public static func `where`(_ name: String, isLessThan value: Any) -> FireThelPredicate {
        .isLessThan(name, value)
    }
    
    public static func `where`(_ name: String, isGreaterThan value: Any) -> FireThelPredicate {
        .isGreaterThan(name, value)
    }
    
    public static func `where`(_ name: String, isLessThanOrEqualTo value: Any) -> FireThelPredicate {
        .isLessThanOrEqualTo(name, value)
    }
    
    public static func `where`(_ name: String,
                               isGreaterThanOrEqualTo value: Any) -> FireThelPredicate {
        .isGreaterThanOrEqualTo(name, value)
    }
}
