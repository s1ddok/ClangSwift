#if !NO_SWIFTPM
import cclang
#endif
import Foundation

public struct Token {
    internal let clang: CXToken

    /// Retrieves the kind of the receiver.
    public var kind: TokenKind {
        return TokenKind(clang: clang_getTokenKind(clang))
    }

    /// Determine the spelling of the given token.
    /// The spelling of a token is the textual representation of that token,
    /// e.g., the text of an identifier or keyword.
    func spelling(in translationUnit: TranslationUnit) -> String {
        return clang_getTokenSpelling(translationUnit.clang, clang).asSwift()
    }

    public func asClang() -> CXToken {
        return clang
    }
}

public struct SourceLocation {
    let clang: CXSourceLocation

    /// Retrieves all file, line, column, and offset attributes of the provided
    /// source location.
    internal var locations: (file: File, line: Int, column: Int, offset: Int) {
        var l = 0 as UInt32
        var c = 0 as UInt32
        var o = 0 as UInt32
        var f: CXFile?
        clang_getFileLocation(clang, &f, &l, &c, &o)
        return (file: File(clang: f!), line: Int(l), column: Int(c), offset: Int(o))
    }

    public func cursor(in translationUnit: TranslationUnit) -> Cursor? {
        return clang_getCursor(translationUnit.clang, clang)
    }

    /// The line to which the given source location points.
    public var line: Int {
        return locations.line
    }

    /// The column to which the given source location points.
    public var column: Int {
        return locations.column
    }

    /// The offset into the buffer to which the given source location points.
    public var offset: Int {
        return locations.offset
    }

    /// The file to which the given source location points.
    public var file: File {
        return locations.file
    }
}

/// Represents a half-open character range in the source code.
public struct SourceRange {
    let clang: CXSourceRange

    /// Retrieve a source location representing the first character within a
    /// source range.
    public var start: SourceLocation {
        return SourceLocation(clang: clang_getRangeStart(clang))
    }

    /// Retrieve a source location representing the last character within a
    /// source range.
    public var end: SourceLocation {
        return SourceLocation(clang: clang_getRangeEnd(clang))
    }
}

/// Represents the different kinds of tokens in C/C++/Objective-C
public enum TokenKind {
    /// A piece of punctuation, like `{`, `;`, and `:`
    case punctuation

    /// A keyword, like `if`, `else`, and `case`
    case keyword

    /// An identifier, like a variable's name or type name
    case identifier

    /// A literal, either character, string, or number
    case literal

    /// A C comment
    case comment

    init(clang: CXTokenKind) {
        switch clang {
        case CXToken_Comment: self = .comment
        case CXToken_Literal: self = .literal
        case CXToken_Identifier: self = .identifier
        case CXToken_Keyword: self = .keyword
        case CXToken_Punctuation: self = .punctuation
        default: fatalError("unknown CXTokenKind \(clang)")
        }
    }

    func asClang() -> CXTokenKind {
        switch self {
        case .comment: return CXToken_Comment
        case .literal: return CXToken_Literal
        case .identifier: return CXToken_Identifier
        case .keyword: return CXToken_Keyword
        case .punctuation: return CXToken_Punctuation
        }
    }
}
