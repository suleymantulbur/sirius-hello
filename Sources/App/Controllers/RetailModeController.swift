import Vapor

struct MoviesController: RouteCollection {
    var app: Application
    let appDirectory:String
    let firestoreService: FirestoreService

    func boot(routes: RoutesBuilder) throws {
        let movies = routes.grouped("retailmode")
        movies.post("upload", use: uploadFile)
    }

    @Sendable
    func uploadFile(req: Request) async throws -> String {
        let input = try req.content.decode(Input.self)
        let data = input.file.data

        do {
            let coverageReport = try! JSONDecoder().decode(Coverage.self, from: data)

            let updateQuery = coverageReport.targets?.first?.files?.compactMap {("users" , Fields(name: .init(stringValue: $0.name!), coverage: .init(doubleValue: $0.coverage!)))}

            guard let updateQuery else {
                throw Abort(.badRequest, reason: "No data to update")
            }

            try await firestoreService.batchWriteData(documents: updateQuery, on: req)
            return "upload completed"
        } catch {
            throw Abort(.badRequest, reason: "JSON parse edilemedi: \(error)")
        }
    }

}
