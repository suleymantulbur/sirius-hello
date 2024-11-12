import Vapor

func routes(_ app: Application) throws {
    let moviesController = MoviesController(app: app, appDirectory: app.directory.publicDirectory,firestoreService: .init(databaseURL: "https://firestore.googleapis.com/v1/projects/tracking-5a183/databases/(default)/documents/"))

    try app.register(collection: moviesController)
}
