import Vapor

struct RegisterRequestDTO: Content {
    let fullName: String
    let phone: String
    let password: String
}

extension RegisterRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("fullName", as: String.self, is: .count(3...))
        validations.add("phone", as: String.self, is: .count(10...15) && .alphanumeric)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User {
    convenience init(from register: RegisterRequestDTO, hash: String) throws {
        self.init(fullName: register.fullName, phone: register.phone, password: hash)
    }
}
