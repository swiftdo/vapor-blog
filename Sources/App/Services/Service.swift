//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

import Vapor

// 服务层，跟 Controller 打交道
public protocol Service {
    init(_ req: Request)
}

public struct ServiceId: Hashable, Equatable, CustomStringConvertible {
    public static func == (lhs: ServiceId, rhs: ServiceId) -> Bool {
        return lhs.type == rhs.type
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type))
    }

    internal let type: Any.Type
    
    public var description: String {
        return "\(type)"
    }
    
    init(_ type: Any.Type) {
        self.type = type
    }
}

public typealias ServiceBuilder = (Request) -> Service

public final class ServiceRegistry {

    private let app: Application
    private var builders: [ServiceId: ServiceBuilder]

    fileprivate init(_ app: Application) {
        self.app = app
        self.builders = [:]
    }

    fileprivate func builder(_ req: Request) -> ServiceFactory {
        .init(req, self)
    }
    
    fileprivate func resolve(_ type: Any.Type, _ req: Request) -> Service {
        let id = ServiceId(type)
        guard let builder = builders[id] else {
            fatalError("Repository for id `\(id)` is not configured.")
        }
        return builder(req)
    }
    
    // TODO: 如何限制 type 继承自 Repository
    public func register(_ type: Any.Type, _ builder: @escaping ServiceBuilder) {
        builders[ServiceId(type)] = builder
    }
}

public struct ServiceFactory {
    private var registry: ServiceRegistry
    private var req: Request
    
    fileprivate init(_ req: Request, _ registry: ServiceRegistry) {
        self.req = req
        self.registry = registry
    }

    public func resolve(_ type: Any.Type) -> Service {
        registry.resolve(type, req)
    }
}

public extension Application {
    private struct Key: StorageKey {
        typealias Value = ServiceRegistry
    }
    
    var services: ServiceRegistry {
        if storage[Key.self] == nil {
            storage[Key.self] = .init(self)
        }
        return storage[Key.self]!
    }
}

public extension Request {
    var services: ServiceFactory {
        application.services.builder(self)
    }
}
