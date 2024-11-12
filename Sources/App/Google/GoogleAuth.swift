import JWTKit
import Vapor

struct GoogleAuth {
    let clientEmail: String = "firebase-adminsdk-inj54@tracking-5a183.iam.gserviceaccount.com"
    let privateKey = "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCTWma+Mpcab320\nR7As0b3OGH1CJkrE5zbqTE5Z5YnczxHxBbhfZeLEa53FOPSBA++HWsWKo7rB3Mxq\n8i07DzvVwTZfB9JXrhkipW4rf59jHhZTbfmxqRW/AtH1GpUTckG+sU5JWNzlG+Sn\nNZe+dOiVu/9uSMhg2GrN3cAkGM/utZvYhh83jE3/r9HabgeSstxb+qQQJ7OKzIkt\niFJI1MeAj9jAX0ZC61pGx33zk589kMMeO6ayo+1wemEBDjxWNV6MfbWCneIPNw6D\ntRQfcLOxydwu5LR7EH75tKT2afT0A2fL1s5Vzgsu3IXr5LtM/SvOpYB+PpifbgSu\n5Bzf57+HAgMBAAECggEAKLFN71eEQBIrCkbD4dS4UHqV2Nc/Tbo2gaS5/Hx1wotS\nvpdgT8QQyEKZ6tWsPBbMproMFJnboN7rettPX2B5GzJE5CCCV6FmIpnB33RanWI5\nMygLTSNPNJVASypgoeKrQlCvuHS4Z/L4ha64ramWc4db5mZmI8yQTjLfdXh+r8J/\nHQ43IMCQxNWBXzG5iuMm9UgdAF1/YdQZVGB44j41zD3kg26U4fkh9bkCW7BNQO+F\njd69GxmyZhPi1YqruqL7qnX1zxD9/OiOHpYtWvhQ0GV05/SE+ylpsNxe+4anlFgs\n3FC4us0biTohfz7fygMgJBXXw7m9r02bEQw2iGGC3QKBgQDKp/jd2B+ul1T3YQeM\nfx9UtD53Q65QmdvBt9ODBoPkDnDVmrTolUNibtwPGT6mI1miCaDyN2siwUPXwJEN\nzNEN/MKWLpeEeEMNtAoD6/2dO1R1UA2C03ZakYF4ASYNu0SdEdViaMcaUxLkkQl8\nfkjDDVL/gvZhnNYn6REflR05gwKBgQC6I9Lor2kX35eCs+qDIV8unyB+POIPzOZa\nJ/Ks5CNwyd92jNRSdCLRHCIsHWPnWrgJxXeMY98dFMhvInAxaSq9slPP105FHtsf\nPeUD8xEm7m5eGhgkC3kdu99phxM+WMBb7FwlVCqWjaRnsC/WgyFSd46p83lcwUSx\nVPOe0Uz2rQKBgGY3ky9Sc6h8bD7akhQrioIO5/MAEExXTqDHN8g+4QeGwSL8hYNK\nxlI/2H9FHHRwICW69ZM2oLNHCBEq7/8l78w+UWeu2H3Yqvmede7EeYd1BYSmfCog\nvvGvsr301lzWuCUBeb/JWaPNgxoGjeJdUBYSAmseg2d41AwNYrWrYLJBAoGAcxDs\nMz0kKUbmAT05LkC19zsVOhRm5r+Sco8ZXDlXk0Sn6EAcjLAQSdYrZbvxYzZYaGny\ngg3HAdI0KUdPtau+aS/Q0b3WO7JcYI7BgNSEeN2Ryog0/is9ft0BudlvUu5IU0rk\nl4rVHOaIiDSJDgFX2wPfZD4Hewhab4kFZNsbya0CgYEAxWq24X4JVMDl5ebVzpwH\nZEZLtxG/2UA+NClSNdXfvWPE2CPDVWsuwEX8cfF7mpAWcxOYhrCmQ83xQexF2kwv\nZW4mx4E2DEVufXIJOG6CKat6Mrf8+VBggiQNyRTgcyxKjfLiG3b9EQnZWhylo8m4\n2QOV1EJ9jnLmfoBOkhTC1JM=\n-----END PRIVATE KEY-----\n"
    let tokenURL = "https://oauth2.googleapis.com/token"
    let scopes = "https://www.googleapis.com/auth/datastore"

    func createJWT() throws -> String {
        let now = Int(Date().timeIntervalSince1970)
        struct JWTClaims: JWTPayload {
            var iss: String
            var sub: String
            var aud: String
            var iat: Int
            var exp: Int
            var scope: String

            func verify(using signer: JWTSigner) throws {}
        }

        let claims = JWTClaims(
            iss: clientEmail,
            sub: clientEmail,
            aud: tokenURL,
            iat: now,
            exp: now + 3600,
            scope: scopes
        )

        let signer = try JWTSigner.rs256(key: .private(pem: privateKey))
        let jwt = try signer.sign(claims)
        return jwt
    }

    func fetchToken(on req: Request) async throws -> String {
        let jwt = try createJWT()
        struct TokenRequest: Content {
            let grant_type: String = "urn:ietf:params:oauth:grant-type:jwt-bearer"
            let assertion: String
        }

        let response = try await req.client.post(URI(string: tokenURL)) { request in
            try request.content.encode(TokenRequest(assertion: jwt), as: .urlEncodedForm)
            request.headers.contentType = .urlEncodedForm
        }

        struct TokenResponse: Content {
            let access_token: String
        }

        guard response.status == .ok else {
            let errorResponse = try response.content.decode([String: String].self)
            throw Abort(.badRequest, reason: errorResponse["error_description"] ?? "Unknown error")
        }

        let tokenResponse = try response.content.decode(TokenResponse.self)
        return tokenResponse.access_token
    }
}
