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

import Testing
import CoreData
import SklvStorage

/// Test suite for the CoreDataManager generic class.
@Suite("CoreDataManager Tests", .serialized)
@MainActor
struct CoreDataManagerTests {

    /// Helper method to initialize an in-memory context for testing.
    private func makeContext() -> NSManagedObjectContext {
        let stack = CoreDataStack(inMemory: true)
        return stack.viewContext
    }

    /// Verifies that new objects can be created and fetched properly.
    @Test
    func createAndFetchAll() throws {
        let context = makeContext()
        let manager = CoreDataManager<Item>(context)

        let item1 = manager.newObject
        item1.id = "item-1"

        let item2 = manager.newObject
        item2.id = "item-2"

        try context.save()

        let results = manager.allObjects
        #expect(results.count == 2)
    }

    /// Verifies that fetchLimit, fetchOffset, and sortDescriptors apply correctly.
    @Test
    func fetchLimitAndOffset() throws {
        let context = makeContext()
        let manager = CoreDataManager<Item>(context)

        for i in 0..<5 {
            let item = manager.newObject
            item.id = "\(i)"
        }

        // Save the context so SQLite can correctly apply the limit and offset.
        try context.save()

        manager.sortDescriptors = [("id", true)]
        manager.fetchLimit = 2
        manager.fetchOffset = 1

        let results = manager.allObjects

        #expect(results.count == 2)
        #expect(results.first?.id == "1")
        #expect(results.last?.id == "2")
    }

    /// Verifies that predicates filter the results and count calculation works.
    @Test
    func predicatesAndCount() throws {
        let context = makeContext()
        let manager = CoreDataManager<Item>(context)

        let item1 = manager.newObject
        item1.id = "target"

        let item2 = manager.newObject
        item2.id = "other"

        try context.save()

        manager.predicate = ("id == %@", ["target"])

        #expect(manager.count == 1)
        #expect(manager.firstObject?.id == "target")
    }

    /// Verifies that deleteAll removes all matching objects efficiently.
    @Test
    func deleteAllObjects() throws {
        let context = makeContext()
        let manager = CoreDataManager<Item>(context)

        _ = manager.newObject
        _ = manager.newObject
        _ = manager.newObject

        try context.save()

        #expect(manager.count == 3)

        manager.deleteAll()

        #expect(manager.count == 0)
    }
}
