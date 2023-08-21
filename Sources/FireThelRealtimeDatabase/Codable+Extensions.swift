//
//  File.swift
//  
//
//  Created by Vebjorn Daniloff on 8/18/23.
//

import Foundation

extension Encodable {
    func dict() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        return try castDataToDict(data: data)
    }

    private func castDataToDict(data: Data) throws -> [String: Any] {
        guard let dict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
            throw RealtimeDatabaseError.defaultCustom("Casting error!")
        }
        return dict
    }
}

enum RealtimeDatabaseError: Error, LocalizedError {
    case `default`(_ error: Error)
    case defaultCustom(_ string: String)
    case someThingWentWrong

    var errorDescription: String? {
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
