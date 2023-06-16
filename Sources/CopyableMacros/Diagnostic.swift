//
//  File.swift
//  
//
//  Created by HyunJin on 2023/06/15.
//

import SwiftDiagnostics

enum CopyableDiagnostic: String, DiagnosticMessage, Error {
    case onlyApplicableToStructAndClass
    
    var message: String {
        switch self {
        case .onlyApplicableToStructAndClass:
            "`@Copyable` can only be applied to `struct` and `class`"
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "CopyableMacro", id: rawValue)
    }
    
    var severity: DiagnosticSeverity {
        switch self {
        case .onlyApplicableToStructAndClass: .error
        }
    }
}
