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

/// Test suite for the Item extensions, verifying value assignment, retrieval, and relationship management.
@Suite("Item Tests", .serialized)
@MainActor
struct ItemTests {

    /// Helper method to initialize an in-memory context for testing.
    private func makeContext() -> NSManagedObjectContext {
        let stack = CoreDataStack(inMemory: true)
        return stack.viewContext
    }

    /// Verifies that assigning a value creates a new element, and assigning it again updates the existing element.
    @Test
    func assignAndFetchValue() throws {
        let context = makeContext()
        let item = Item(context: context)

        // Assign a new value
        item.assignValue("Hello", forKey: "greeting")

        let fetchedString: String? = item.fetchValue(forKey: "greeting")
        #expect(fetchedString == "Hello")

        // Ensure only one element was created
        let initialElements = item.elements as? Set<Element> ?? []
        #expect(initialElements.count == 1)

        // Update the existing value
        item.assignValue("World", forKey: "greeting")

        let updatedString: String? = item.fetchValue(forKey: "greeting")
        #expect(updatedString == "World")

        // Ensure a duplicate element was not created
        let updatedElements = item.elements as? Set<Element> ?? []
        #expect(updatedElements.count == 1)
    }

    /// Verifies that providing an empty key gracefully fails without modifying the object or throwing errors.
    @Test
    func emptyKeyHandling() {
        let context = makeContext()
        let item = Item(context: context)

        item.assignValue(42, forKey: "")

        let elementsSet = item.elements as? Set<Element> ?? []
        #expect(elementsSet.isEmpty == true)

        let fetched: Int? = item.fetchValue(forKey: "")
        #expect(fetched == nil)
    }

    /// Verifies that removing a value nullifies the relationship and updates the in-memory graph immediately.
    @Test
    func removeValueUpdatesObjectGraphImmediately() throws {
        let context = makeContext()
        let item = Item(context: context)

        item.assignValue(100, forKey: "score")

        let elementsBeforeRemoval = item.elements as? Set<Element> ?? []
        #expect(elementsBeforeRemoval.count == 1)

        item.removeValue(forKey: "score")

        let fetched: Int? = item.fetchValue(forKey: "score")
        #expect(fetched == nil)

        // Verify that explicitly setting element.item = nil immediately removes it from the item's elements set
        let elementsAfterRemoval = item.elements as? Set<Element> ?? []
        #expect(elementsAfterRemoval.isEmpty == true)
    }
}
