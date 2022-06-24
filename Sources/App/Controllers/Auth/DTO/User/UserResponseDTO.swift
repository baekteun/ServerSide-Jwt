import Vapor

struct UserResponseDTO: Content {
    let fullName: String
    let phone: String
    var isAdmin: Bool
}

extension UserResponseDTO {
    init(with user: User) {
        self.fullName = user.fullName
        self.phone = user.phone
        self.isAdmin = user.isAdmin
    }
}
