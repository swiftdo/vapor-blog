//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

import Vapor

// 主要目标是从数据库中高效地访问(查询)数据，并向服务层提供服务。
public protocol Repository {
    init(_ req: Request)
}

public struct RepositoryId: Hashable, Equatable, CustomStringConvertible {
    public static func == (lhs: RepositoryId, rhs: RepositoryId) -> Bool {
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

public typealias RepositoryBuilder = (Request) -> Repository

public final class RepositoryRegistry {

    private let app: Application
    private var builders: [RepositoryId: RepositoryBuilder]

    fileprivate init(_ app: Application) {
        self.app = app
        self.builders = [:]
    }

    fileprivate func builder(_ req: Request) -> RepositoryFactory {
        .init(req, self)
    }
    
    fileprivate func resolve(_ type: Any.Type, _ req: Request) -> Repository {
        let id = RepositoryId(type)
        guard let builder = builders[id] else {
            fatalError("Repository for id `\(id)` is not configured.")
        }
        return builder(req)
    }
    
    // TODO: 如何限制 type 继承自 Repository
    public func register(_ type: Any.Type, _ builder: @escaping RepositoryBuilder) {
        builders[RepositoryId(type)] = builder
    }
}

public struct RepositoryFactory {
    private var registry: RepositoryRegistry
    private var req: Request
    
    fileprivate init(_ req: Request, _ registry: RepositoryRegistry) {
        self.req = req
        self.registry = registry
    }

    public func resolve(_ type: Any.Type) -> Repository {
        registry.resolve(type, req)
    }
}

public extension Application {
    private struct Key: StorageKey {
        typealias Value = RepositoryRegistry
    }
    
    var repositories: RepositoryRegistry {
        if storage[Key.self] == nil {
            storage[Key.self] = .init(self)
        }
        return storage[Key.self]!
    }
}

public extension Request {
    var repositories: RepositoryFactory {
        application.repositories.builder(self)
    }
}
