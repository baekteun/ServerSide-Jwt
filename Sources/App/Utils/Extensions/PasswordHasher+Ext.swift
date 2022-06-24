import Vapor

extension PasswordHasher {
    public func hash(_ password: String) async throws -> String {
        return try String(decoding: self.hash([UInt8](password.utf8)), as: UTF8.self)
    }

    public func verify(_ password: String, created digest: String) async throws -> Bool {
        return try self.verify(
            [UInt8](password.utf8),
            created: [UInt8](digest.utf8)
        )
    }
}
