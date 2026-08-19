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

extension NSFetchedResultsController where ResultType == Item {
    /// Retrieves the item at the specified row and section without relying on UIKit extensions for IndexPath.
    /// - Parameters:
    ///   - row: The row index of the item.
    ///   - section: The section index of the item.
    /// - Returns: The item located at the specified position.
    public func object(atRow row: Int, inSection section: Int) -> Item {
        object(at: IndexPath(indexes: [section, row]))
    }

    /// Determines the row and section for a given item without relying on UIKit extensions for IndexPath.
    /// - Parameter item: The item to locate within the fetched results.
    /// - Returns: A tuple containing the row and section if the item is found and the index path is valid; otherwise, `nil`.
    public func position(forItem item: Item) -> (row: Int, section: Int)? {
        guard let indexPath = indexPath(forObject: item),
              indexPath.count >= 2 else {
            return nil
        }

        return (row: indexPath[1], section: indexPath[0])
    }
}
