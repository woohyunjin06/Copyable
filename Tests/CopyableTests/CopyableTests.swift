import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import CopyableMacros

let testMacros: [String: Macro.Type] = [
    "Copyable": CopyableMacro.self,
]

final class CopyableTests: XCTestCase {
    func test_macro_expansion() {
        assertMacroExpansion(
            """
            @Copyable struct Model {
                let stringValue: String
                let optionalStringValue: String?
                let integerValue: Int
            }
            """,
            expandedSource: """
            struct Model {
                let stringValue: String
                let optionalStringValue: String?
                let integerValue: Int
                init(
                    stringValue: String,
                    optionalStringValue: String?,
                    integerValue: Int,
                    forCopyable: Void? = nil
                ) {
                    self.stringValue = stringValue
                    self.optionalStringValue = optionalStringValue
                    self.integerValue = integerValue
                }
                struct Builder {
                    var stringValue: String
                    var optionalStringValue: String?
                    var integerValue: Int

                    fileprivate init(original: Model) {
                        self.stringValue = original.stringValue
                        self.optionalStringValue = original.optionalStringValue
                        self.integerValue = original.integerValue
                    }

                    fileprivate func toModel() -> Model {
                        Model(
                            stringValue: stringValue,
                            optionalStringValue: optionalStringValue,
                            integerValue: integerValue
                        )
                    }
                }
                func copy(build: (inout Builder) -> Void) -> Model {
                    var builder = Builder(original: self)
                    build(&builder)
                    return builder.toModel()
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func test_protocol_copyable_fails() throws {
        assertMacroExpansion(
            """
            @Copyable protocol ProtocolType {
            }
            """,
            expandedSource: """
            protocol ProtocolType {
            }
            """,
            diagnostics: [
                .init(message: "`@Copyable` can only be applied to `struct` and `class`", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
}
