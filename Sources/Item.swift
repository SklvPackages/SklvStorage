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

extension Item {
    /// Retrieves the value of the specified type associated with the given key.
    /// - Parameter key: The identifier for the stored value.
    /// - Returns: The underlying value cast to `T`, or `nil` if the key is empty, not found, or the type mismatches.
    public func fetchValue<T: Sendable>(forKey key: String) -> T? {
        guard !key.isEmpty else { return nil }

        let elementsSet = (elements as? Set<Element>) ?? []
        return elementsSet.first { $0.key == key }?.fetchValue()
    }

    /// Assigns a value to the specified key.
    /// If an element with the given key already exists, its value is updated.
    /// Otherwise, a new element is created and linked to this item.
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The identifier for the stored value.
    public func assignValue<T: Sendable>(_ value: T, forKey key: String) {
        guard !key.isEmpty else { return }

        let elementsSet = (elements as? Set<Element>) ?? []

        if let element = elementsSet.first(where: { $0.key == key }) {
            element.assignValue(value)
        } else if let context = managedObjectContext {
            let object = Element(context: context)
            object.key = key
            object.assignValue(value)
            object.item = self
        }
    }

    /// Removes the element associated with the given key from the item.
    /// The element's relationship to the item is explicitly nullified to immediately update the in-memory object graph before deletion.
    /// - Parameter key: The identifier of the element to remove.
    public func removeValue(forKey key: String) {
        guard !key.isEmpty, let context = managedObjectContext else { return }

        let elementsSet = (elements as? Set<Element>) ?? []

        if let element = elementsSet.first(where: { $0.key == key }) {
            element.item = nil
            context.delete(element)
        }
    }
}
