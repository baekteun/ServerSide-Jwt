import Vapor
import Fluent
import AsyncHTTPClient
import JWT
import Foundation

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("auth") { route in
            route.post("register", use: register)
            route.post("login", use: login)
            route.patch("refresh", use: refresh)
            
            route.group(UserAuthenticator()) { route in
                route.get("me", use: me)
                route.delete("logout", use: logout)
            }
        }
    }
}

private extension AuthController {
    func register(_ req: Request) async throws -> HTTPStatus {
        do {
            try RegisterRequestDTO.validate(content: req)
        } catch {
            throw AuthError.invalidPhoneOrPassword
        }
        let register = try req.content.decode(RegisterRequestDTO.self)
        if let _ = try await req.users.find(phone: register.phone) {
            throw AuthError.phoneAlreadyExists
        }
        
        let hash = try await req.password.hash(register.password)
        let user = try User(from: register, hash: hash)
        try await req.users.save(user)
        
        return .ok
    }
    func login(_ req: Request) async throws -> TokenResponse {
        do {
            try LoginRequestDTO.validate(content: req)
        } catch {
            throw AuthError.invalidPhoneOrPassword
        }
        let login = try req.content.decode(LoginRequestDTO.self)
        guard let user = try await req.users.find(phone: login.phone) else { throw AuthError.userNotFound }
        guard try await req.password.verify(login.password, created: user.password) else { throw AuthError.invalidPhoneOrPassword }
        let access = try req.jwt.sign(Payload(with: user))
        let refresh = try req.jwt.sign(Payload(with: user))
        if let existRefreshToken = try await req.refreshTokens.find(userID: user.id ?? .init()) {
            try await req.refreshTokens.set(\.$token, to: refresh, for: existRefreshToken.id ?? .init())
        } else {
            try await req.refreshTokens.save(.init(token: refresh, userID: user.id ?? .init()))
        }
        
        return TokenResponse(accessToken: access, refreshToken: refresh, expiredAt: Date().addingTimeInterval(Const.ACCESS_EXP).ISO8601Format())
    }
    func refresh(_ req: Request) async throws -> TokenResponse {
        guard let refresh = req.headers.bearerAuthorization?.token else { throw AuthError.refreshTokenOrUserNotFound }
        guard let find = try await req.refreshTokens.find(token: refresh) else { throw AuthError.refreshTokenOrUserNotFound }
        guard let user = try await req.users.find(id: find.$user.id) else { throw AuthError.userNotFound }
        let accessGen = try req.jwt.sign(Payload(with: user))
        let refreshGen = try req.jwt.sign(Payload(with: user))
        if let existRefreshToken = try await req.refreshTokens.find(userID: user.id ?? .init()) {
            try await req.refreshTokens.set(\.$token, to: refreshGen, for: existRefreshToken.id ?? .init())
        } else {
            try await req.refreshTokens.save(.init(token: refreshGen, userID: user.id ?? .init()))
        }
        return TokenResponse(accessToken: accessGen, refreshToken: refreshGen, expiredAt: Date().addingTimeInterval(Const.ACCESS_EXP).ISO8601Format())
    }
    func me(_ req: Request) async throws -> UserResponseDTO {
        let payload = try req.auth.require(Payload.self)
        guard let user = try await req.users.find(id: payload.userID) else { throw AuthError.userNotFound }
        return UserResponseDTO(with: user)
    }
    func logout(_ req: Request) async throws -> HTTPStatus {
        let payload = try req.auth.require(Payload.self)
        try await req.refreshTokens.delete(for: payload.userID)
        return .ok
    }
}
