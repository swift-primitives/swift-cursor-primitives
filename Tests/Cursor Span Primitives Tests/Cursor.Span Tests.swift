// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-cursor-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-cursor-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing
import Cursor_Primitives_Test_Support

private enum TestDomain {}

// MARK: - Test Suite Structure

extension Cursor {
    @Suite struct `Span Test` {}
}

extension Cursor.`Span Test` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit

extension Cursor.`Span Test`.Unit {
    @Test
    func `init at zero with empty source`() {
        let bytes: [UInt8] = []
        unsafe bytes.withUnsafeBufferPointer { buf in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            let cursor = Cursor.Span<TestDomain>(span)
            let atEnd = cursor.isAtEnd
            let peeked = cursor.peek()
            #expect(atEnd)
            #expect(peeked == nil)
        }
    }

    @Test
    func `init at zero with non-empty source`() {
        let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04]
        unsafe bytes.withUnsafeBufferPointer { buf in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            let cursor = Cursor.Span<TestDomain>(span)
            let atEnd = cursor.isAtEnd
            let peeked = cursor.peek()
            #expect(!atEnd)
            #expect(peeked == 0x01)
        }
    }

    @Test
    func `peek does not advance`() {
        let bytes: [UInt8] = [0x42, 0x43]
        unsafe bytes.withUnsafeBufferPointer { buf in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            let cursor = Cursor.Span<TestDomain>(span)
            let first = cursor.peek()
            let second = cursor.peek()
            #expect(first == 0x42)
            #expect(second == 0x42)
        }
    }

    @Test
    func `peek at offset reads ahead`() {
        let bytes: [UInt8] = [0xAA, 0xBB, 0xCC, 0xDD]
        unsafe bytes.withUnsafeBufferPointer { buf in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            let cursor = Cursor.Span<TestDomain>(span)
            let at0 = cursor.peek(at: Tagged<TestDomain, Cardinal>(_unchecked: Cardinal(UInt(0))))
            let at2 = cursor.peek(at: Tagged<TestDomain, Cardinal>(_unchecked: Cardinal(UInt(2))))
            let past = cursor.peek(at: Tagged<TestDomain, Cardinal>(_unchecked: Cardinal(UInt(4))))
            #expect(at0 == 0xAA)
            #expect(at2 == 0xCC)
            #expect(past == nil)
        }
    }

    @Test
    func `advance moves cursor forward`() {
        let bytes: [UInt8] = [0x01, 0x02, 0x03]
        unsafe bytes.withUnsafeBufferPointer { buf in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            var cursor = Cursor.Span<TestDomain>(span)
            cursor.advance()
            let after1 = cursor.peek()
            cursor.advance()
            let after2 = cursor.peek()
            #expect(after1 == 0x02)
            #expect(after2 == 0x03)
        }
    }

    @Test
    func `consume reads and advances`() {
        let bytes: [UInt8] = [0x10, 0x20, 0x30]
        unsafe bytes.withUnsafeBufferPointer { buf in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            var cursor = Cursor.Span<TestDomain>(span)
            let a = cursor.consume()
            let b = cursor.consume()
            let c = cursor.consume()
            let atEnd = cursor.isAtEnd
            #expect(a == 0x10)
            #expect(b == 0x20)
            #expect(c == 0x30)
            #expect(atEnd)
        }
    }

    @Test
    func `count reflects remaining bytes`() {
        let bytes: [UInt8] = [1, 2, 3, 4, 5]
        unsafe bytes.withUnsafeBufferPointer { buf in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            var cursor = Cursor.Span<TestDomain>(span)
            let initialCount = Int(bitPattern: cursor.count)
            #expect(initialCount == 5)
            cursor.advance()
            let afterOne = Int(bitPattern: cursor.count)
            #expect(afterOne == 4)
            cursor.advance(by: Tagged<TestDomain, Cardinal>(_unchecked: Cardinal(UInt(3))))
            let afterFour = Int(bitPattern: cursor.count)
            #expect(afterFour == 1)
        }
    }
}

// MARK: - Edge Case

extension Cursor.`Span Test`.`Edge Case` {
    @Test
    func `isAtEnd true after consuming all bytes`() {
        let bytes: [UInt8] = [0xFF]
        unsafe bytes.withUnsafeBufferPointer { buf in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            var cursor = Cursor.Span<TestDomain>(span)
            _ = cursor.consume()
            let atEnd = cursor.isAtEnd
            let peeked = cursor.peek()
            #expect(atEnd)
            #expect(peeked == nil)
        }
    }

    @Test
    func `count is zero on empty source`() {
        let bytes: [UInt8] = []
        unsafe bytes.withUnsafeBufferPointer { buf in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            let cursor = Cursor.Span<TestDomain>(span)
            let initialCount = Int(bitPattern: cursor.count)
            #expect(initialCount == 0)
        }
    }
}

// MARK: - Integration

extension Cursor.`Span Test`.Integration {
    @Test
    func `drains every byte via consume loop`() {
        let bytes: [UInt8] = (0..<32).map { UInt8($0) }
        let collected: [UInt8] = unsafe bytes.withUnsafeBufferPointer { buf -> [UInt8] in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            var cursor = Cursor.Span<TestDomain>(span)
            var out: [UInt8] = []
            while !cursor.isAtEnd {
                out.append(cursor.consume())
            }
            return out
        }
        #expect(collected == bytes)
    }

    @Test
    func `peek + advance loop matches consume loop`() {
        let bytes: [UInt8] = (0..<32).map { UInt8($0) }
        let collected: [UInt8] = unsafe bytes.withUnsafeBufferPointer { buf -> [UInt8] in
            let span = unsafe Swift.Span(_unsafeElements: buf)
            var cursor = Cursor.Span<TestDomain>(span)
            var out: [UInt8] = []
            while let b = cursor.peek() {
                out.append(b)
                cursor.advance()
            }
            return out
        }
        #expect(collected == bytes)
    }
}

// MARK: - Performance
//
// Substantive performance tests live in the BENCH-011 experiment at
// /Users/coen/Developer/swift-institute/Experiments/cursor-span-bench-011/
// where Binary.Bytes.Input.View and Lexer.Scanner are available for
// comparison without creating a dependency cycle here. The Performance
// suite stays empty at the package level — its existence satisfies
// [TEST-005]'s four-category structure.
