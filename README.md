# SklvStorage

[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_15.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

A lightweight, thread-safe, and modern Core Data wrapper built for Swift 6. `SklvStorage` is designed to enforce Clean Architecture by keeping UI frameworks (like `UIKit`) out of your data and presentation layers while fully embracing Swift's strict concurrency.

## Features

- 🚀 **Concurrency Ready:** Built around Swift 6 Strict Concurrency with `@MainActor` and a custom `BackgroundActor` for safe background processing.
- 🛠 **Generic Data Manager:** Simplified CRUD operations, sorting, and filtering without boilerplate fetch requests.
- 🗂 **Dynamic Key-Value Storage:** Type-safe extensions to assign and fetch dynamic values on entities without altering the Core Data schema.
- 🚫 **No UIKit Dependency:** `NSFetchedResultsController` extensions that allow row and section indexing perfectly suited for Presenters or ViewModels.

## Requirements

- **iOS** 15.0+
- **Xcode** 26.0+
- **Swift** 6.3+

## Installation

### Swift Package Manager

1. Inside Xcode, navigate to **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/SklvPackages/SklvStorage.git`
3. Define the dependency rules to **Up to Next Major** starting with `1.0.0`.

## Usage

### 1. Initializing the Stack
Set up the Core Data stack. It automatically handles the persistent container and configures the main and background contexts with the correct merge policies.

```swift
import SklvStorage

// Initialize the standard database
let database = CoreDataStack()

// Or initialize an in-memory database for testing
let memoryDatabase = CoreDataStack(inMemory: true)
```

### 2. Performing Background Tasks
Safely execute database operations off the main thread. The `BackgroundActor` automatically saves the context if changes were made.

```swift
Task {
    try await database.backgroundContext.perform { context in
        let newItem = Item(context: context)
        newItem.id = UUID().uuidString
        // The context is automatically saved at the end of this block
    }
}
```

### 3. Using the Data Manager
`CoreDataManager` simplifies fetching, counting, and deleting entities on your view context.

```swift
let manager = CoreDataManager<Item>(database.viewContext)

// Configure fetch parameters
manager.sortDescriptors = [("date", false)]
manager.fetchLimit = 20
manager.predicate = ("flag0 == %@", [true])

// Fetch objects
let items = manager.allObjects
let totalCount = manager.count

// Delete objects
manager.deleteAll()
```

### 4. Dynamic Key-Value Attributes
Store and retrieve arbitrary values type-safely using the `Element` relationship without needing to migrate your Core Data model for every new property.

```swift
let item = manager.newObject

// Assign values
item.assignValue("John Doe", forKey: "username")
item.assignValue(42, forKey: "age")

// Fetch values type-safely
let username: String? = item.fetchValue(forKey: "username")
let age: Int? = item.fetchValue(forKey: "age")

// Remove a value
item.removeValue(forKey: "age")
```

### 5. UIKit-Independent FetchedResultsController
Access positioning data in your Presenter/ViewModel without importing `UIKit` or dealing with `IndexPath`.

```swift
let controller = manager.fetchedResultsController
try? controller.performFetch()

// Safely get item position (returns a tuple: (row: Int, section: Int)?)
if let position = controller.position(forItem: someItem) {
    print("Item is at row \(position.row) in section \(position.section)")
}

// Safely get an object by row and section
let item = controller.object(atRow: 0, inSection: 1)
```

## License

`SklvStorage` is released under the MIT license. See [LICENSE](LICENSE) for details.
