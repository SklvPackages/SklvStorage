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

import Foundation

extension Element {
    /// Retrieves the stored value cast to the specified generic type.
    /// - Returns: The underlying value cast to `T`, or `nil` if the type does not match or is unsupported.
    public func fetchValue<T: Sendable>() -> T? {
        switch T.self {
        case is String.Type:
            return string as? T
        case is Int.Type:
            return Int(integer64) as? T
        case is Double.Type:
            return double as? T
        case is Bool.Type:
            return boolean as? T
        case is Date.Type:
            return date as? T
        case is Data.Type:
            return data as? T
        default:
            return nil
        }
    }

    /// Assigns a value to the appropriate underlying entity attribute based on its type.
    /// Empty strings and empty data objects are automatically stored as `nil`.
    /// - Parameter value: The value to store. Supported types include `String`, `Int`, `Double`, `Bool`, `Date`, and `Data`.
    public func assignValue(_ value: any Sendable) {
        switch value {
        case let string as String:
            self.string = string.isEmpty ? nil : string
        case let int as Int:
            self.integer64 = Int64(int)
        case let double as Double:
            self.double = double
        case let bool as Bool:
            self.boolean = bool
        case let date as Date:
            self.date = date
        case let data as Data:
            self.data = data.isEmpty ? nil : data
        default:
            break
        }
    }
}
