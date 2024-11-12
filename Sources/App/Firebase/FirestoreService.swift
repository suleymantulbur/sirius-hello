import Vapor

struct FirestoreService {
    let databaseURL: String
    let googleAuth: GoogleAuth = GoogleAuth()

    func batchWriteData(documents: [(collection: String, data: Fields)], on req: Request) async throws {
        let token = try await googleAuth.fetchToken(on: req)

        let url = "\(databaseURL):commit"
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(token)")
        headers.add(name: .contentType, value: "application/json")

        let writes = documents.map { doc in
            FirestoreWrite(
                update: FirestoreDocument(
                    name: "projects/tracking-5a183/databases/(default)/documents/users/\(doc.data.name.stringValue)",
                    fields: doc.data
                )
            )
        }

        let batchRequest = FirestoreBatchRequest(writes: writes)

        let response = try await req.client.post(URI(string: url), headers: headers, content: batchRequest)
        guard response.status == .ok else {
            let errorResponse = try response.content.decode([String: String].self)
            throw Abort(.badRequest, reason: errorResponse["error_description"] ?? "Batch write failed")
        }
    }
}
