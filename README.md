# QDataManager

![![GitHub license][LicenseBadge]](https://raw.githubusercontent.com/dhatuna/QDataManager/master/LICENSE) [![Swift6 compatible][Swift6Badge]][Swift6Link]

QDataManager is a lightweight and flexible data management framework for Swift, built on **SQLite3**, that provides secure encoding, automatic database handling, and easy-to-use property management.

## Features

- **SQLite3-based storage**: Efficient data persistence using SQLite3.
- **NSSecureCoding support**: Ensures secure data archiving and unarchiving.
- **Automatic persistence**: Easily save and load data with minimal effort.
- **Property management**: Use `@QDataProperty` for automatic serialization.
- **Swift Package Manager (SPM) support**: Easily integrate into your project.

## Installation

### Using Swift Package Manager (SPM)

To add `QDataManager` to your project, follow these steps:

1. Open Xcode and go to `File` > `Add Packages`.
2. Enter the repository URL:
   ```
   https://github.com/your-username/QDataManager.git
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

QDataManager is developed and maintained by [Your Name]. If you find this project useful, consider giving it a star on GitHub!

[Swift]: https://swift.org/
[SQLite3]: https://www.sqlite.org

[GitHubActionBadge]: https://github.com/dhatuna/QDataManager/actions/workflows/ci.yml/badge.svg

[LicenseBadge]: https://img.shields.io/badge/license-MIT-blue.svg

[Swift6Badge]: https://img.shields.io/badge/swift-6-orange.svg?style=flat
[Swift6Link]: https://developer.apple.com/swift/
