import Foundation

@MainActor
public protocol UseCase<Input, Output> {
    associatedtype Input
    associatedtype Output
    
    @discardableResult func execute(_ input: Input) async -> Result<Output, Error>
    @discardableResult func execute() async -> Result<Output, Error>
}

@MainActor
public protocol SyncUseCase<Input, Output> {
    associatedtype Input
    associatedtype Output
    
    @discardableResult func execute(_ input: Input) -> Result<Output, Error>
    @discardableResult func execute() -> Result<Output, Error>
}

public extension UseCase {
    func execute(_ input: Input) async -> Result<Output, Error> {
        fatalError("\(#function) not implemented")
    }
    
    func execute() async -> Result<Output, Error> {
        fatalError("\(#function) not implemented")
    }
}

public extension SyncUseCase {
    func execute(_ input: Input) -> Result<Output, Error> {
        fatalError("\(#function) not implemented")
    }
    
    func execute() -> Result<Output, Error> {
        fatalError("\(#function) not implemented")
    }
}
