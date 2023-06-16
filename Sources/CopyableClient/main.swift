import Copyable

@Copyable
struct Model {
    let stringValue: String
    let optionalStringValue: String?
    let integerValue: Int
}

let model = Model(
    stringValue: "String Value",
    optionalStringValue: "Optional Value",
    integerValue: 5
)

let copiedModel = model.copy {
    $0.stringValue = "Modified String Value"
    $0.optionalStringValue = nil
}
