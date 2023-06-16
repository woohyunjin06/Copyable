//
//  Plugin.swift
//
//
//  Created by HyunJin on 2023/06/13.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct CopyablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CopyableMacro.self,
    ]
}
