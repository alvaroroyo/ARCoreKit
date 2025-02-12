import Foundation

@MainActor
public protocol UseCase<Input, Output> {
    associatedtype Input
    associatedtype Output
    
    func execute(_ input: Input) async -> Result<Output, Error>
    func execute() async -> Result<Output, Error>
}

public extension UseCase {
    func execute(_ input: Input) async -> Result<Output, Error> {
        fatalError("\(#function) not implemented")
    }
    
    func execute() async -> Result<Output, Error> {
        fatalError("\(#function) not implemented")
    }
}
