# Copyable
`Copyable` is a Swift package that provides the ability to copy and modify structs with let properties.

# Installation

## Swift Package Manager

In `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/woohyunjin06/Copyable.git", from: "1.0.0")
]
```

And then add the dependency to your targets.

# Usage
1. Declare a copyable struct using the @Copyable attribute. Here's an example code:
   ```swift
   import Copyable

    @Copyable
    struct Model {
        let value: String
    }
    ```
2. Use the copy function to copy and modify the struct. The copy function takes a closure as an argument, allowing you to modify the struct's properties within the closure.
    ```swift
    let model = Model(value: "value")
    let modified = model.copy {
        $0.value = "modifiedValue"
    }
    ```

# License
Copyable is available under the MIT license. See the [LICENSE](LICENSE) for details.