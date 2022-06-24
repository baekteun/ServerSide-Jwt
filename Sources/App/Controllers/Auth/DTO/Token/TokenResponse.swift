import Vapor
import Foundation

struct TokenResponse: Content {
    let accessToken: String
    let refreshToken: String
    let expiredAt: String
}
