import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CopyableMacro: MemberMacro {
    struct Property {
        let identifier: String
        let type: TypeSyntax
    }
    
    public static func expansion<
        Declaration: DeclGroupSyntax,
        Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let typeName = declaration.as(StructDeclSyntax.self)?.identifier.text else {
            throw CopyableDiagnostic.onlyApplicableToStructAndClass
        }
        let members = declaration.memberBlock.members
        let properties: [Property] = members.compactMap {
            guard let binding = $0.decl.as(VariableDeclSyntax.self)?.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let type = binding.typeAnnotation?.type
            else { return nil }
            return Property(identifier: identifier, type: type)
        }
        
        return [
            initializer(properties: properties),
            builderType(typeName: typeName, properties: properties),
            copyFunction(typeName: typeName, properties: properties)
        ].compactMap { $0 }
    }
    
    private static func initializer(properties: [Property]) -> DeclSyntax? {
        let initializerArguments: [String] = properties.map {
            return "    \($0.identifier): \($0.type)"
        }
        
        let initializerBody: [String] = properties.map {
            return "    self.\($0.identifier) = \($0.identifier)"
        }
        
        return DeclSyntax("""
        init(
        \(raw: initializerArguments.joined(separator: ",\n")),
            forCopyable: Void? = nil
        ) {
        \(raw: initializerBody.joined(separator: "\n"))
        }
        """)
    }
    
    private static func builderType(typeName: String, properties: [Property]) -> DeclSyntax {
        let propertyDeclarations: [String] = properties.map {
            return "    var \($0.identifier): \($0.type)"
        }
        
        let initializerBody = properties.map {
            return "        self.\($0.identifier) = original.\($0.identifier)"
        }
        
        let mapperBody = properties.map {
            return "            \($0.identifier): \($0.identifier)"
        }
        
        return DeclSyntax("""
        struct Builder {
        \(raw: propertyDeclarations.joined(separator: "\n"))
        
            fileprivate init(original: \(raw: typeName)) {
        \(raw: initializerBody.joined(separator: "\n"))
            }
        
            fileprivate func to\(raw: typeName)() -> \(raw: typeName) {
                \(raw: typeName)(
        \(raw: mapperBody.joined(separator: ",\n"))
                )
            }
        }
        """)
    }
    
    private static func copyFunction(typeName: String, properties: [Property]) -> DeclSyntax {
        return DeclSyntax("""
        func copy(build: (inout Builder) -> Void) -> \(raw: typeName) {
            var builder = Builder(original: self)
            build(&builder)
            return builder.to\(raw: typeName)()
        }
        """)
    }
}
