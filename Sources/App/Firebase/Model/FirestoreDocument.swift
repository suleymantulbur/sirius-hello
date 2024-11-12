import Vapor

struct FirestoreDocument: Content {
    let name: String
    let fields: Fields
}

struct Fields: Codable {
    let name: FirestoreStringValue
    let coverage: FirestoreDoubleValue
}

struct FirestoreStringValue: Codable {
    let stringValue: String
}

struct FirestoreDoubleValue: Codable {
    let doubleValue: Double
}
