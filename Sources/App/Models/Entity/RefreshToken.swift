import Vapor
import Fluent
import Foundation

final class RefreshToken: Model {
    static let schema: String = "refresh_token"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token")
    var token: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "expired_at")
    var expiredAt: Date
    
    @Field(key: "issued_at")
    var issuedAt: Date
    
    init() {}
    
    init(
        id: UUID? = nil,
        token: String,
        userID: UUID,
        expiredAt: Date = Date().addingTimeInterval(Const.REFRESH_EXP),
        issuedAt: Date = Date()
    ) {
        self.id = id
        self.token = token
        self.$user.id = userID
        self.expiredAt = expiredAt
        self.issuedAt = issuedAt
    }
}
