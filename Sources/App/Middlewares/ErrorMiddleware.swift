//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

import Vapor

extension ErrorMiddleware {
    public static func custom(environment: Environment) -> ErrorMiddleware {
        return .init { req, error in
            let status: HTTPResponseStatus
            let reason: String
            let headers: HTTPHeaders
            var code: Int?

            switch error {
            case let abort as AbortError:
                reason = abort.reason
                status = abort.status
                headers = abort.headers

                if let apierror = abort as? ApiError {
                    code = apierror.content.code
                }

            default:
                reason = environment.isRelease
                    ? "Something went wrong."
                    : String(describing: error)
                status = .internalServerError
                headers = [:]
            }

            req.logger.report(error: error)
            let response = Response(status: status, headers: headers)

            do {
                let errorResponse = OutStatus(code: code ?? 1008611, message: reason)
                response.body = try .init(data: JSONEncoder().encode(errorResponse))
                response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                response.body = .init(string: "Oops: \(error)")
                response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return response
        }
    }
}
