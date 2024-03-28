//  Inject.swift
//  Created by Alvaro Royo on 28/3/24.

import Foundation

@available(iOS 13.0, *)
@propertyWrapper
public class Inject<Value>: ObservableObject {
    private let name: String?
    private var storage: Value?
    
    public var wrappedValue: Value {
        storage ?? {
            let value: Value = CoreServiceLocator.shared.module(for: Value.self)
            storage = value
            return value
        }()
    }
    
    public init() {
        self.name = nil
    }
    
    public init(_ type: Value.Type = Value.self) {
        self.name = String(describing: Value.self)
    }
}
