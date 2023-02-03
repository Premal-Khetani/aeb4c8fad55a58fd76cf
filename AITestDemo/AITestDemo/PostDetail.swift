//
//
// Product: APITestCallAI
// Project: APITestCallAI
// Package: APITestCallAI
//


import Foundation

// MARK: - Hits
class PostDetail: Codable {
    let hits: [Hit]
    let nbHits, page, nbPages, hitsPerPage: Int
    let exhaustiveNbHits, exhaustiveTypo: Bool
    let exhaustive: Exhaustive
    let query, params: String
    let processingTimeMS: Int
    let processingTimingsMS: ProcessingTimingsMS
    let serverTimeMS: Int

    init(hits: [Hit], nbHits: Int, page: Int, nbPages: Int, hitsPerPage: Int, exhaustiveNbHits: Bool, exhaustiveTypo: Bool, exhaustive: Exhaustive, query: String, params: String, processingTimeMS: Int, processingTimingsMS: ProcessingTimingsMS, serverTimeMS: Int) {
        self.hits = hits
        self.nbHits = nbHits
        self.page = page
        self.nbPages = nbPages
        self.hitsPerPage = hitsPerPage
        self.exhaustiveNbHits = exhaustiveNbHits
        self.exhaustiveTypo = exhaustiveTypo
        self.exhaustive = exhaustive
        self.query = query
        self.params = params
        self.processingTimeMS = processingTimeMS
        self.processingTimingsMS = processingTimingsMS
        self.serverTimeMS = serverTimeMS
    }
}

// MARK: - Exhaustive
class Exhaustive: Codable {
    let nbHits, typo: Bool

    init(nbHits: Bool, typo: Bool) {
        self.nbHits = nbHits
        self.typo = typo
    }
}

// MARK: - Hit
class Hit: Codable {
    let createdAt, title: String
    let url: String?
    let author: String
    let points: Int
    let storyText: String?
    let commentText: JSONNull?
    let numComments: Int
    let storyID, storyTitle, storyURL, parentID: JSONNull?
    let createdAtI: Int
    let tags: [String]
    let objectID: String
    let highlightResult: HighlightResult

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case title, url, author, points
        case storyText = "story_text"
        case commentText = "comment_text"
        case numComments = "num_comments"
        case storyID = "story_id"
        case storyTitle = "story_title"
        case storyURL = "story_url"
        case parentID = "parent_id"
        case createdAtI = "created_at_i"
        case tags = "_tags"
        case objectID
        case highlightResult = "_highlightResult"
    }

    init(createdAt: String, title: String, url: String?, author: String, points: Int, storyText: String?, commentText: JSONNull?, numComments: Int, storyID: JSONNull?, storyTitle: JSONNull?, storyURL: JSONNull?, parentID: JSONNull?, createdAtI: Int, tags: [String], objectID: String, highlightResult: HighlightResult) {
        self.createdAt = createdAt
        self.title = title
        self.url = url
        self.author = author
        self.points = points
        self.storyText = storyText
        self.commentText = commentText
        self.numComments = numComments
        self.storyID = storyID
        self.storyTitle = storyTitle
        self.storyURL = storyURL
        self.parentID = parentID
        self.createdAtI = createdAtI
        self.tags = tags
        self.objectID = objectID
        self.highlightResult = highlightResult
    }
}

// MARK: - HighlightResult
class HighlightResult: Codable {
    let title: Author
    let url: Author?
    let author: Author
    let storyText: Author?

    enum CodingKeys: String, CodingKey {
        case title, url, author
        case storyText = "story_text"
    }

    init(title: Author, url: Author?, author: Author, storyText: Author?) {
        self.title = title
        self.url = url
        self.author = author
        self.storyText = storyText
    }
}

// MARK: - Author
class Author: Codable {
    let value: String
    let matchLevel: MatchLevel
    let matchedWords: [JSONAny]

    init(value: String, matchLevel: MatchLevel, matchedWords: [JSONAny]) {
        self.value = value
        self.matchLevel = matchLevel
        self.matchedWords = matchedWords
    }
}

enum MatchLevel: String, Codable {
    case none = "none"
}

// MARK: - ProcessingTimingsMS
class ProcessingTimingsMS: Codable {
//    let fetch: Fetch
    let request: Request
    let total: Int
//fetch: Fetch,
    init( request: Request, total: Int) {
//        self.fetch = fetch
        self.request = request
        self.total = total
    }
}

// MARK: - Fetch
//class Fetch: Codable {
//    let scanning, total: Int
//
//    init(scanning: Int, total: Int) {
//        self.scanning = scanning
//        self.total = total
//    }
//}

// MARK: - Request
class Request: Codable {
    let roundTrip: Int

    init(roundTrip: Int) {
        self.roundTrip = roundTrip
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public func hash(into hasher: inout Hasher) {
            hasher.combine(0)
        }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
