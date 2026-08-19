//
//  Copyright (c) 2026 Andrew Sokolov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import CoreData

/// An actor that provides thread-safe, serialized execution for Core Data background operations.
public actor BackgroundActor {
    private let context: NSManagedObjectContext

    /// Initializes the actor with a specific background context.
    /// - Parameter context: The managed object context to be used for background tasks.
    init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    /// Executes a closure on the background context's queue, automatically saving any changes.
    /// - Parameter block: The closure to execute.
    /// - Returns: The result of the executed closure.
    @discardableResult
    public func perform<T: Sendable>(_ block: @escaping @Sendable (NSManagedObjectContext) throws -> T) async throws -> T {
        try await context.perform { [context] in
            let result = try block(context)

            if context.hasChanges {
                try context.save()
            }

            return result
        }
    }
}

/// The main entry point for the Core Data stack, managing the persistent container.
@MainActor
public final class CoreDataStack {
    private let container: NSPersistentContainer

    /// The main thread context, optimized for reading data to the UI.
    public let viewContext: NSManagedObjectContext

    /// The background actor, optimized for writing and processing data.
    public let backgroundContext: BackgroundActor

    /// Initializes the Core Data stack.
    /// - Parameter inMemory: A Boolean value indicating whether the store should reside in memory only.
    public init(inMemory: Bool = false) {
        let modelName = "SklvDatabase"

        guard let modelURL = Bundle.module.url(forResource: modelName, withExtension: "momd") else {
            fatalError("[CoreDataStack] Model file '\(modelName).xcdatamodeld' not found in Bundle.module")
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("[CoreDataStack] Failed to initialize NSManagedObjectModel from URL: \(modelURL)")
        }

        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)

        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = false
            description.shouldInferMappingModelAutomatically = false

            if inMemory {
                description.url = URL(fileURLWithPath: "/dev/null")
            }
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("[CoreDataStack] Container loading failed: \(error), \(error.userInfo)")
            }
        }

        self.container = container

        let viewContext = container.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.undoManager = nil
        self.viewContext = viewContext

        let backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        backgroundContext.automaticallyMergesChangesFromParent = false
        backgroundContext.undoManager = nil
        self.backgroundContext = BackgroundActor(backgroundContext)
    }
}
