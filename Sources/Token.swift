//
//  Token.swift
//  TokensView
//
//  Created by Sergey Atroschenko on 18.04.22.
//  Copyright © 2022 TokensView. All rights reserved.
//

import Foundation

public class Token: Equatable, Hashable {
    public let title: String
    public let hexString: String
    
    public init(title: String, hexString: String) {
        self.title = title
        self.hexString = hexString
    }
    
    public static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.title == rhs.title
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
