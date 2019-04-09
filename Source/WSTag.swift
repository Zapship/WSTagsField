//
//  WSTag.swift
//  Whitesmith
//
//  Created by Ricardo Pereira on 12/05/16.
//  Copyright © 2016 Whitesmith. All rights reserved.
//

import Foundation

public struct WSTag: Hashable {

    public let text: String
    public let hasMoreOptions: Bool
    private let otherOptions: [String]?

    public init(_ text: String, otherOptions: [String]? = []) {
        self.text = text
        self.otherOptions = otherOptions
        self.hasMoreOptions = otherOptions != nil && otherOptions!.count > 0
    }

    public var hashValue: Int {
        return self.text.hashValue
    }

    public func equals(_ other: WSTag) -> Bool {
        return self.text == other.text
    }

}

public func == (lhs: WSTag, rhs: WSTag) -> Bool {
    return lhs.equals(rhs)
}
