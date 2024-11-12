import Vapor

struct FirestoreBatchRequest: Content {
    let writes: [FirestoreWrite]
}

struct FirestoreWrite: Content {
    let update: FirestoreDocument
}
