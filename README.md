# QDataManager

QDataManager is a lightweight and flexible data management framework for Swift that provides secure encoding, automatic database handling, and easy-to-use property management.

## Features

- **NSSecureCoding support**: Ensures secure data archiving and unarchiving.
- **Automatic persistence**: Easily save and load data with minimal effort.
- **Property management**: Use `@QDataProperty` for automatic serialization.
- **SQLite integration**: Built-in lightweight SQLite support.
- **Swift Package Manager (SPM) support**: Easily integrate into your project.

## Installation

### Using Swift Package Manager (SPM)

To add `QDataManager` to your project, follow these steps:

1. Open Xcode and go to `File` > `Add Packages`.
2. Enter the repository URL:
   ```
   https://github.com/dhatuna/QDataManager.git
   ```
3. Select the latest version and click `Add Package`.
4. Import QDataManager in your project:
   ```swift
   import QDataManager
   ```

## Usage

### Define a Data Manager

Create a custom data manager by subclassing `QDataManager` and use `@QDataProperty` to define properties.

```swift
import QDataManager

class UserDataManager: QDataManager {
    @QDataProperty("username") var username: String?
    @QDataProperty("email") var email: String?
}
```

### Saving Data

```swift
let userManager = UserDataManager.loadDatabase()
userManager.username = "john_doe"
userManager.email = "john@example.com"
userManager.commit()
```

### Loading Data

```swift
let loadedManager = UserDataManager.loadDatabase()
print("Username: \(loadedManager.username ?? "Unknown")")
print("Email: \(loadedManager.email ?? "Unknown")")
```

## Handling Secure Coding

Ensure that your subclass implements `supportsSecureCoding`:

```swift
class UserDataManager: QDataManager {
    override class var supportsSecureCoding: Bool {
        return true
    }
}
```

## License

QDataManager is available under the MIT license. See the [LICENSE](LICENSE) file for more details.

## Contributing

Contributions are welcome! Feel free to open issues and pull requests to improve QDataManager.

## Author

QDataManager is developed and maintained by JK Jeon. If you find this project useful, consider giving it a star on GitHub!

