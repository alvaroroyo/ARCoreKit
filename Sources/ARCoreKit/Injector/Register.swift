//  Register.swift
//  Created by Alvaro Royo on 28/3/24.

import Foundation

public enum StoragePolicy {
    case unique //Singleton
    case new //One new value per request
}

public struct Register {
    let name: String
    let storagePolicy: StoragePolicy
    let resolve: () -> Any
    
    public init<T>(
        _ type: T.Type = T.self,
        _ storagePolicy: StoragePolicy = .new,
        _ resolve: @escaping () -> T
    ) {
        self.name = String(describing: T.self)
        self.storagePolicy = storagePolicy
        self.resolve = resolve
    }
}
