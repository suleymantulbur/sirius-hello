import Vapor

struct Input: Content {
    var file: File
    var fileName: String
}
