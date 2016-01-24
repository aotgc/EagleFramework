/*
 * Copyright (C) 2015 Josh A. Beam
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

public extension String {
    private static func ucharToChar(c: CUnsignedChar) -> CChar {
        if c < 128 {
            return CChar(c)
        } else {
            return CChar(-128) | CChar(c & 0b01111111)
        }
    }

    /// A UTF-8 C-string representation of the string.
    public var utf8CString: [CChar] {
        return self.nulTerminatedUTF8.map({ String.ucharToChar($0) })
    }

    private var fstatMode: mode_t {
        var fd = open(self.utf8CString, O_RDONLY)
        guard fd != -1 else {
            return 0
        }

        defer {
            close(fd)
        }

        var status = stat()
        guard fstat(fd, &status) != -1 else {
            return 0
        }

        return status.st_mode
    }

    // Indicates whether or not the string contains the path of a directory.
    public var isDirectory: Bool {
        return (fstatMode & S_IFDIR) != 0
    }

    // Indicates whether or not the string contains the path of a regular file.
    public var isFile: Bool {
        return (fstatMode & S_IFREG) != 0
    }

    /// The string's character count.
    public var length: Int {
        return self.characters.count
    }

    /// Creates a string by replacing all occurrences
    /// of a substring with a replacement string.
    ///
    /// - parameter target: The substring to replace.
    /// - parameter withString: The replacement string.
    /// - returns: A new string with all occurrences
    ///   of the given substring replaced.
    public func replace(target: String, withString replacement: String) -> String {
        var s1 = ""
        var s2 = self

        while let range = s2.rangeOfString(target) {
            s1 += s2.substringWithRange(Range(start: s2.startIndex, end: range.startIndex))
            s1 += replacement
            s2 = s2.substringWithRange(Range(start: range.endIndex, end: s2.endIndex))
        }

        return s1 + s2
    }

    /// Splits a string using a given delimiter.
    ///
    /// - parameter delimiter: The delimiter to use to split the string.
    /// - returns: An array containing the components of the string
    ///   separated by the given delimiter.
    public func split(delimiter: String) -> [String] {
        var s = self
        var components: [String] = []

        while let range = s.rangeOfString(delimiter) {
            components.append(s.substringWithRange(Range(start: s.startIndex, end: range.startIndex)))
            s = s.substringWithRange(Range(start: range.endIndex, end: s.endIndex))
        }

        // If there are any characters left, we'll
        // include them as the last component.
        if s.length > 0 {
            components.append(s)
        }

        return components
    }

    /// Gets a substring of the string.
    ///
    /// - parameter startIndex: The starting index to create the substring from.
    /// - parameter length: The length of the substring.
    /// - returns: A substring from the starting index and with the given length.
    public func substring(startIndex: Int, length: Int) -> String {
        let start = self.startIndex.advancedBy(startIndex)
        let end = start.advancedBy(length)
        return self.substringWithRange(Range(start: start, end: end))
    }

    /// Gets a substring of the string.
    ///
    /// - parameter startIndex: The starting index to create the substring from.
    /// - returns: A substring from the starting index up to the end of the string.
    public func substring(startIndex: Int) -> String {
        let start = self.startIndex.advancedBy(startIndex)
        let end = self.endIndex
        return self.substringWithRange(Range(start: start, end: end))
    }

    /// Checks whether or not the given character is a whitespace character.
    ///
    /// - parameter c: The character to check.
    /// - returns: true if the character is a whitespace character, false otherwise.
    public static func isWhitespace(c: Character) -> Bool {
        return c == " " || c == "\r" || c == "\n" || c == "\r\n" || c == "\t"
    }

    /// A copy of the string with all beginning and trailing whitespace characters removed.
    public var trimmed: String {
        var s = self

        while !s.isEmpty && String.isWhitespace(s.characters[s.startIndex]) {
            s = s.substringWithRange(Range(start: s.startIndex.successor(), end: s.endIndex))
        }

        while !s.isEmpty && String.isWhitespace(s.characters[s.endIndex.predecessor()]) {
            s = s.substringWithRange(Range(start: s.startIndex, end: s.endIndex.predecessor()))
        }

        return s
    }

    /// A copy of the string safe for inclusion in HTML content.
    public var htmlSafe: String {
        let replacements = [
            "<": "&lt;",
            ">": "&gt;",
            "\"": "&quot;"
        ]

        var s = self.replace("&", withString: "&amp;")
        for (key, value) in replacements {
            s = s.replace(key, withString: value)
        }

        return s
    }
}
