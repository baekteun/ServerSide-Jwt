import Vapor
import Fluent
import AsyncHTTPClient
import Foundation

protocol UserRepository: Repository {
    func save(_ user: User) async throws
    func all() async throws -> [User]
    func find(id: UUID?) async throws -> User?
    func find(phone: String) async throws -> User?
    func delete(id: UUID) async throws
    func set<Field>(_ field: KeyPath<User, Field>, to value: Field.Value, for userID: UUID) async throws -> Void where Field: QueryableProperty, Field.Model == User
    func count() async throws -> Int
}

struct DatabaseUserRepository: UserRepository, DatabaseRepository {
    let database: Database
    
    func save(_ user: User) async throws {
        try await user.create(on: database)
    }
    
    func all() async throws -> [User] {
        try await User.query(on: database).all()
    }
    
    func find(id: UUID?) async throws -> User? {
        try await User.find(id, on: database)
    }
    
    func find(phone: String) async throws -> User? {
        try await User.query(on: database)
            .filter(\.$phone == phone)
            .first()
    }
    
    func delete(id: UUID) async throws {
        try await User.query(on: database)
            .filter(\.$id == id)
            .delete()
    }
    
    func set<Field>(
        _ field: KeyPath<User, Field>,
        to value: Field.Value,
        for userID: UUID
    ) async throws where Field : QueryableProperty, Field.Model == User {
        try await User.query(on: database)
            .filter(\.$id == userID)
            .set(field, to: value)
            .update()
    }
    
    func count() async throws -> Int {
        try await User.query(on: database).count()
    }
}

extension Application.Repositories {
    var users: UserRepository {
        guard let storage = storage.makeUserRepository else {
            fatalError()
        }
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (UserRepository)) {
        _ = storage
        app.storage[Key.self]?.makeUserRepository = make
    }
}
