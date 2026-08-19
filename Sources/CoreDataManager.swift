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

/// A generic manager to simplify Core Data fetch requests, counting, and object creation.
public final class CoreDataManager<Entity: NSManagedObject> {
    private let context: NSManagedObjectContext

    /// Optional sorting parameters applied to the fetch request.
    public var sortDescriptors: [(key: String, ascending: Bool)]?

    /// Optional predicate format and arguments for filtering objects.
    public var predicate: (format: String, argumentArray: [any Sendable])?

    /// An optional key path used to group results into sections for the fetched results controller.
    public var sectionNameKeyPath: String?

    /// The batch size for fetching objects. Defaults to 0.
    public var fetchBatchSize: Int = 0

    /// The maximum number of objects to fetch. Defaults to 0 (no limit).
    public var fetchLimit: Int = 0

    /// The offset to apply when fetching objects. Defaults to 0.
    public var fetchOffset: Int = 0

    /// Initializes the manager with a specific managed object context.
    /// - Parameter context: The context used for fetching and managing entities.
    public init(_ context: NSManagedObjectContext) {
        self.context = context
    }
}

extension CoreDataManager {
    /// The configured fetch request based on the manager's current properties.
    private var request: NSFetchRequest<Entity> {
        let name = String(describing: Entity.self)
        let request = NSFetchRequest<Entity>(entityName: name)

        request.sortDescriptors = sortDescriptors?.map {
            NSSortDescriptor(key: $0.key, ascending: $0.ascending)
        }

        if let predicate {
            request.predicate = NSPredicate(format: predicate.format,
                                            argumentArray: predicate.argumentArray)
        }

        request.fetchBatchSize = fetchBatchSize
        request.fetchLimit = fetchLimit
        request.fetchOffset = fetchOffset

        return request
    }
}

extension CoreDataManager {
    /// Fetches and returns all objects matching the current configuration. Returns an empty array on failure.
    public var allObjects: [Entity] {
        (try? context.fetch(request)) ?? []
    }

    /// Fetches and returns the first object matching the current configuration, if any.
    public var firstObject: Entity? {
        let req = request
        req.fetchLimit = 1
        return try? context.fetch(req).first
    }

    /// Creates and returns a new entity instance in the managed object context.
    public var newObject: Entity {
        Entity(context: context)
    }
}

extension CoreDataManager {
    /// Returns the total number of objects matching the current configuration. Returns 0 on failure.
    public var count: Int {
        (try? context.count(for: request)) ?? 0
    }

    /// Creates and returns a fetched results controller based on the current configuration.
    /// - Note: The `sortDescriptors` property must not be nil or empty before calling this.
    public var fetchedResultsController: NSFetchedResultsController<Entity> {
        precondition(sortDescriptors?.isEmpty == false)

        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil
        )
    }
}

extension CoreDataManager {
    /// Deletes a specific object from the context.
    /// - Parameter object: The entity to delete.
    public func delete(_ object: Entity) {
        context.delete(object)
    }

    /// Deletes an array of objects from the context.
    /// - Parameter objects: The collection of entities to delete.
    public func delete(_ objects: [Entity]) {
        for object in objects {
            context.delete(object)
        }
    }

    /// Deletes all objects matching the current configuration efficiently by omitting property values during the fetch.
    public func deleteAll() {
        let req = request
        req.includesPropertyValues = false

        if let objects = try? context.fetch(req) {
            delete(objects)
        }
    }
}
