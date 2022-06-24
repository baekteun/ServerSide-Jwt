import Vapor

struct LoginRequestDTO: Content {
    let phone: String
    let password: String
}

extension LoginRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("phone", as: String.self, is: .alphanumeric)
        validations.add("password", as: String.self, is: !.empty)
    }
}
