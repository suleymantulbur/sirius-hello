import Vapor

public func configure(_ app: Application) async throws {
    app.routes.defaultMaxBodySize = "10mb"
    try routes(app)
}
