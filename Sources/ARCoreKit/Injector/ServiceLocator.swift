//  ServiceLocator.swift
//  Created by Alvaro Royo on 28/3/24.

import Foundation

public protocol ServiceLocator {
    var root: CoreServiceLocator { get }
    func services() -> [Register]
}

public extension ServiceLocator {
    var root: CoreServiceLocator {
        CoreServiceLocator.shared
    }
    
    func services() -> [Register] {
        []
    }
}


public final class CoreServiceLocator {
    // Stored object instance factories
    private var services = [String: Register]()
    // Stored unique object instances
    private var uniqueInstances = [String: Any]()
    
    init() {}
    deinit { services.removeAll() }
}

extension CoreServiceLocator {
    public static let shared = CoreServiceLocator()
    
    public func add(@Factory _ module: () -> Register) {
        let module = module()
        services[module.name] = module
    }
    
    public func add(@Factory _ modules: () -> [Register]) {
        modules().forEach {
            services[$0.name] = $0
        }
    }
    
    public func removeAll() {
        services.removeAll()
        uniqueInstances.removeAll()
    }
    
    public func module<T>(for type: T.Type = T.self) -> T {
        let name = String(describing: T.self)
        guard let service = services[name] else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }
        
        switch service.storagePolicy {
        case .unique:
            if let uniqueInstance = uniqueInstances[name] as? T {
                return uniqueInstance
            } else {
                let instance = service.resolve()
                uniqueInstances[name] = instance
                return instance as! T
            }
        case .new:
            return service.resolve() as! T
        }
    }
}

public extension CoreServiceLocator {
    @resultBuilder struct Factory {
        public static func buildBlock(_ modules: Register...) -> [Register] { modules }
        public static func buildBlock(_ module: Register) -> Register { module }
    }
}
