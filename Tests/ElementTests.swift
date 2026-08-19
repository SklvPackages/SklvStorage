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

/// Test suite for the Element extensions, verifying type-safe value assignment and retrieval.
@Suite("Element Tests", .serialized)
@MainActor
struct ElementTests {

    /// Helper method to initialize an in-memory context for testing.
    private func makeContext() -> NSManagedObjectContext {
        let stack = CoreDataStack(inMemory: true)
        return stack.viewContext
    }

    /// Verifies that standard scalar and date values are properly assigned and retrieved.
    @Test
    func basicValueAssignmentAndRetrieval() {
        let context = makeContext()
        let element = Element(context: context)

        // Test Int
        element.assignValue(42)
        let intValue: Int? = element.fetchValue()
        #expect(intValue == 42)
        #expect(element.integer64 == 42)

        // Test Double
        element.assignValue(3.14)
        let doubleValue: Double? = element.fetchValue()
        #expect(doubleValue == 3.14)
        #expect(element.double == 3.14)

        // Test Bool
        element.assignValue(true)
        let boolValue: Bool? = element.fetchValue()
        #expect(boolValue == true)
        #expect(element.boolean == true)

        // Test Date
        let date = Date(timeIntervalSince1970: 1000)
        element.assignValue(date)
        let dateValue: Date? = element.fetchValue()
        #expect(dateValue == date)
        #expect(element.date == date)
    }

    /// Verifies that strings and data are assigned correctly, and that empty values are stored as nil.
    @Test
    func collectionTypesAndEmptyHandling() {
        let context = makeContext()
        let element = Element(context: context)

        // Test valid String
        element.assignValue("Hello")
        let stringValue: String? = element.fetchValue()
        #expect(stringValue == "Hello")

        // Test empty String (should become nil)
        element.assignValue("")
        let emptyStringValue: String? = element.fetchValue()
        #expect(emptyStringValue == nil)
        #expect(element.string == nil)

        // Test valid Data
        let data = Data([0x01, 0x02])
        element.assignValue(data)
        let dataValue: Data? = element.fetchValue()
        #expect(dataValue == data)

        // Test empty Data (should become nil)
        element.assignValue(Data())
        let emptyDataValue: Data? = element.fetchValue()
        #expect(emptyDataValue == nil)
        #expect(element.data == nil)
    }

    /// Verifies that unsupported types are safely ignored during assignment and return nil on fetch.
    @Test
    func unsupportedTypeHandling() {
        let context = makeContext()
        let element = Element(context: context)

        // Struct that is not handled in the switch statements
        struct CustomType: Sendable {}
        let customValue = CustomType()

        // Assigning should fall through to default without crashing
        element.assignValue(customValue)

        // Fetching should return nil
        let fetchedCustomValue: CustomType? = element.fetchValue()
        #expect(fetchedCustomValue == nil)
    }
}
