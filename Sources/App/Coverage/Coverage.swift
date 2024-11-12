public struct Coverage: Codable {
    public let coverage: Double?
    public let targets: [Target]?

    public enum CodingKeys: String, CodingKey {
        case coverage = "coverage"
        case targets = "targets"
    }

    public init(coverage: Double?, targets: [Target]?) {
        self.coverage = coverage
        self.targets = targets
    }
}

// MARK: - Target
public struct Target: Codable {
    public let name: String?
    public let coverage: Double?
    public let files: [CoverageFile]?

    public enum CodingKeys: String, CodingKey {
        case name = "name"
        case coverage = "coverage"
        case files = "files"
    }

    public init(name: String?, coverage: Double?, files: [CoverageFile]?) {
        self.name = name
        self.coverage = coverage
        self.files = files
    }
}

// MARK: - File
public struct CoverageFile: Codable {
    public let name: String?
    public let coverage: Double?

    public enum CodingKeys: String, CodingKey {
        case name = "name"
        case coverage = "coverage"
    }

    public init(name: String?, coverage: Double?) {
        self.name = name
        self.coverage = coverage
    }
}
