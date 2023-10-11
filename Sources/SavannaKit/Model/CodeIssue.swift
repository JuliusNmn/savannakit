//
//  CodeIssue.swift
//  SavannaKit
//
//  Created by Julius Naeumann on 16.12.21.
//  Copyright © 2021 Silver Fox. All rights reserved.
//

import Foundation

public enum CodeIssueType {
    case Error
    case Warning
}

public class CodeIssue {
    public let message: String
    public let line: Int
    public let charStart: Int
    public let charEnd: Int
    public let type: CodeIssueType
    
    public init(
        message: String,
        line: Int,
        charStart: Int,
        charEnd: Int,
        type: CodeIssueType
    ) {
        self.message = message
        self.line = line
        self.charStart = charStart
        self.charEnd = charEnd
        self.type = type
    }
}
