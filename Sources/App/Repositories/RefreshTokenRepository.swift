import Vapor
import Fluent
import AsyncHTTPClient
import Foundation

protocol RefreshTokenRepository: Repository {
    func save(_ token: RefreshToken) async throws
    func set<Field>(_ field: KeyPath<RefreshToken, Field>, to value: Field.Value, for userID: UUID) async throws -> Void where Field: QueryableProperty, Field.Model == RefreshToken
    func find(id: UUID?) async throws -> RefreshToken?
    func find(token: String) async throws -> RefreshToken?
    func find(userID: UUID) async throws -> RefreshToken?
    func delete(_ token: RefreshToken) async throws
    func delete(for userID: UUID) async throws
    func count() async throws -> Int
}

struct DatabaseRefreshTokenRepository: RefreshTokenRepository, DatabaseRepository {
    let database: Database
    
    func save(_ token: RefreshToken) async throws {
        try await token.create(on: database)
    }
    
    func set<Field>(
        _ field: KeyPath<RefreshToken, Field>,
        to value: Field.Value,
        for id: UUID
    ) async throws where Field : QueryableProperty, Field.Model == RefreshToken {
        try await RefreshToken.query(on: database)
            .filter(\.$id == id)
            .set(field, to: value)
            .update()
    }
    
    func find(id: UUID?) async throws -> RefreshToken? {
        try await RefreshToken.find(id, on: database)
    }
    
    func find(userID: UUID) async throws -> RefreshToken? {
        try await RefreshToken.query(on: database)
            .filter(\.$user.$id == userID)
            .first()
    }
    
    func find(token: String) async throws -> RefreshToken? {
        try await RefreshToken.query(on: database)
            .filter(\.$token == token)
            .first()
    }
    
    func delete(_ token: RefreshToken) async throws {
        try await token.delete(on: database)
    }
    
    func delete(for userID: UUID) async throws {
        try await RefreshToken.query(on: database)
            .filter(\.$user.$id == userID)
            .delete()
    }
    
    func count() async throws -> Int {
        try await RefreshToken.query(on: database).count()
    }
}

extension Application.Repositories {
    var refreshTokens: RefreshTokenRepository {
        guard let factory = storage.makeRefreshTokenRepository else {
            fatalError()
        }
        return factory(app)
    }
    
    func use(_ make: @escaping (Application) -> (RefreshTokenRepository)) {
        _ = storage
        app.storage[Key.self]?.makeRefreshTokenRepository = make
    }
}
