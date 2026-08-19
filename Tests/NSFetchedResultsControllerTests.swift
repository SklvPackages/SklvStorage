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

/// Test suite for the NSFetchedResultsController extensions focusing on UIKit-independent indexing.
@Suite("NSFetchedResultsController Tests", .serialized)
@MainActor
struct FetchedResultsControllerTests {

    /// Helper method to initialize an in-memory context and pre-populate a fetched results controller.
    private func makeConfiguredController() throws -> (NSManagedObjectContext, NSFetchedResultsController<Item>, [Item]) {
        let stack = CoreDataStack(inMemory: true)
        let context = stack.viewContext

        let item1 = Item(context: context)
        item1.id = "A"

        let item2 = Item(context: context)
        item2.id = "B"

        try context.save()

        let request = NSFetchRequest<Item>(entityName: String(describing: Item.self))
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        try controller.performFetch()

        return (context, controller, [item1, item2])
    }

    /// Verifies that an object can be successfully retrieved using a specific row and section.
    @Test
    func objectAtRowAndSection() throws {
        let (_, controller, items) = try makeConfiguredController()

        let firstFetchedItem = controller.object(atRow: 0, inSection: 0)
        let secondFetchedItem = controller.object(atRow: 1, inSection: 0)

        #expect(firstFetchedItem == items[0])
        #expect(secondFetchedItem == items[1])
    }

    /// Verifies that the correct row and section tuple is returned for a valid item.
    @Test
    func positionForValidItem() throws {
        let (_, controller, items) = try makeConfiguredController()

        let firstPosition = controller.position(forItem: items[0])
        let secondPosition = controller.position(forItem: items[1])

        #expect(firstPosition?.row == 0)
        #expect(firstPosition?.section == 0)

        #expect(secondPosition?.row == 1)
        #expect(secondPosition?.section == 0)
    }

    /// Verifies that position retrieval gracefully returns nil for an item that is not in the fetch results.
    @Test
    func positionForUnknownItem() throws {
        let (context, controller, _) = try makeConfiguredController()

        let unknownItem = Item(context: context)
        unknownItem.id = "C"
        // This item is added to the context but not saved or fetched by the controller yet.

        let position = controller.position(forItem: unknownItem)

        #expect(position == nil)
    }
}
