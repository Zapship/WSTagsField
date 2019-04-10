//
//  WSTag.swift
//  Whitesmith
//
//  Created by Ricardo Pereira on 12/05/16.
//  Copyright © 2016 Whitesmith. All rights reserved.
//

import Foundation

public struct WSTag {

    public let id: String
    public let text: String
    public let otherOptions: [String]

    public init(id: String, text: String, otherOptions: [String] = []) {
        self.id = id
        self.text = text
        self.otherOptions = otherOptions
    }
}
