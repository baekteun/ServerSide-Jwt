import Vapor
import JWT
import Foundation

struct Payload: JWTPayload, Authenticatable {
    // User
    var userID: UUID
    var fullName: String
    var phone: String
    var isAdmin: Bool
    
    // Jwt
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
    
    init(with user: User) throws {
        self.userID = try user.requireID()
        self.fullName = user.fullName
        self.phone = user.phone
        self.isAdmin = user.isAdmin
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(Const.ACCESS_EXP))
    }
}

extension User {
    convenience init(from payload: Payload) {
        self.init(
            id: payload.userID,
            fullName: payload.fullName,
            phone: payload.phone,
            password: "",
            isAdmin: payload.isAdmin
        )
    }
}
