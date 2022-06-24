import Vapor
import Fluent
import JWT
import JWTKit

final class User: Model, Authenticatable {
    static let schema: String = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "full_name")
    var fullName: String
    
    @Field(key: "phone")
    var phone: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "is_admin")
    var isAdmin: Bool
    
    @Field(key: "is_active")
    var isActive: Bool
    
    init() {}
    
    init(
        id: UUID? = nil,
        fullName: String,
        phone: String,
        password: String,
        isAdmin: Bool = false,
        isActive: Bool = false
    ) {
        self.id = id
        self.fullName = fullName
        self.phone = phone
        self.password = password
        self.isAdmin = isAdmin
        self.isActive = isActive
    }
}
