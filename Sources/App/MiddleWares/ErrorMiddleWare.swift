import Vapor
import Foundation

struct ErrorResponse: Codable {
    var error: Bool
    var reason: String
    var errorCode: String?
}

extension ErrorMiddleware {
    static func custom(environment: Environment) -> ErrorMiddleware {
        return .init { req, err in
            let status: HTTPResponseStatus
            let errorResponse: ErrorResponse?
            let headers: HTTPHeaders
            
            switch err {
            case let appError as AppError:
                status = appError.status
                errorResponse = ErrorResponse(error: true, reason: appError.reason, errorCode: appError.identifier)
                headers = appError.headers
            case let abort as AbortError:
                status = abort.status
                errorResponse = ErrorResponse(error: true, reason: abort.reason, errorCode: nil)
                headers = abort.headers
            case let e as LocalizedError where !environment.isRelease:
                status = .internalServerError
                errorResponse = ErrorResponse(error: true, reason: e.localizedDescription, errorCode: nil)
                headers = [:]
            default:
                status = .internalServerError
                errorResponse = ErrorResponse(error: true, reason: "Something went wrong", errorCode: nil)
                headers = [:]
            }
            
            req.logger.report(error: err)
            
            let res = Response(status: status, headers: headers)
            
            do {
                res.body = try .init(data: JSONEncoder().encode(errorResponse))
                res.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                res.body = .init(string: "Oops: \(error)")
                res.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return res
        }
    }
}
