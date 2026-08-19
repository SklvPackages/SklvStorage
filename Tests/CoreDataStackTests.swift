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

/// Test suite for the Core Data Stack setup and background operations.
@Suite("CoreDataStack Tests", .serialized)
@MainActor
struct CoreDataStackTests {

    /// Verifies that the stack initializes correctly in memory and configures contexts properly.
    @Test
    func initialization() {
        let stack = CoreDataStack(inMemory: true)

        // Verify the configuration of the non-optional viewContext.
        #expect(stack.viewContext.concurrencyType == .mainQueueConcurrencyType)
        #expect(stack.viewContext.automaticallyMergesChangesFromParent == true)
        #expect(stack.viewContext.mergePolicy as? NSMergePolicy === NSMergePolicy.mergeByPropertyStoreTrump)
    }

    /// Verifies that the background actor executes tasks, saves changes, and returns the expected result.
    @Test
    func backgroundActorPerformAndSave() async throws {
        let stack = CoreDataStack(inMemory: true)

        let resultID = try await stack.backgroundContext.perform { context in
            let item = Item(context: context)
            item.id = "test-123"
            return item.id
        }

        #expect(resultID == "test-123")
    }

    /// Verifies that changes made and saved in the background context are correctly merged into the view context.
    @Test
    func changesMergeToViewContext() async throws {
        let stack = CoreDataStack(inMemory: true)

        try await stack.backgroundContext.perform { context in
            let item = Item(context: context)
            item.id = "merged-item"
        }

        // Yield the thread briefly to allow the main runloop to process the NSManagedObjectContextDidSave notification.
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds

        let request = NSFetchRequest<Item>(entityName: String(describing: Item.self))
        request.predicate = NSPredicate(format: "id == %@", "merged-item")

        let results = try stack.viewContext.fetch(request)

        #expect(results.count == 1)
        #expect(results.first?.id == "merged-item")
    }
}
