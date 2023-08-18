//
//  File.swift
//  
//
//  Created by Vebjørn Daniloff on 24/05/2023.
//

import Foundation

///// Default error.
public enum CustomError: Error, LocalizedError {
    case `default`(_ error: Error)
    case defaultCustom(_ string: String)
    case someThingWentWrong

    public var errorDescription: String? {
        switch self {
        case let .default(err):
            return err.localizedDescription

        case .someThingWentWrong:
            return NSLocalizedString("Something went wrong.", comment: "")

        case let .defaultCustom(customErrorString):
            return NSLocalizedString(customErrorString, comment: "")
        }
    }
}
