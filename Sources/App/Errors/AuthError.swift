import Vapor

enum AuthError: AppError {
    case phoneAlreadyExists
    case invalidPhoneOrPassword
    case refreshTokenOrUserNotFound
    case accessTokenHasExpired
    case refreshTokenHasExpired
    case userNotFound
}

extension AuthError {
    var status: HTTPResponseStatus {
        switch self {
        case .phoneAlreadyExists:
            return .conflict
        case .invalidPhoneOrPassword:
            return .unauthorized
        case .refreshTokenOrUserNotFound, .userNotFound:
            return .notFound
        case .accessTokenHasExpired, .refreshTokenHasExpired:
            return .unauthorized
        }
    }
    
    var reason: String {
        switch self {
        case .phoneAlreadyExists:
            return "번호가 이미 존재합니다."
        case .invalidPhoneOrPassword:
            return "번호 또는 패스워드가 유효하지 않습니다."
        case .refreshTokenOrUserNotFound, .userNotFound:
            return "유저를 찾을 수 없습니다."
        case .accessTokenHasExpired:
            return "액세스 토큰이 만료되었습니다."
        case .refreshTokenHasExpired:
            return "리프레시 토큰이 만료되었습니다."
        }
    }
    
    var identifier: String {
        switch self {
        case .phoneAlreadyExists:
            return "phone_already_exists"
        case .invalidPhoneOrPassword:
            return "invalid_email_or_password"
        case .refreshTokenOrUserNotFound:
            return "refresh_token_or_user_not_found"
        case .accessTokenHasExpired:
            return "access_token_has_expired"
        case .refreshTokenHasExpired:
            return "refresh_token_has_expired"
        case .userNotFound:
            return "user_not_found"
        }
    }
}
