import Foundation
import Combine

private struct Case<AssociatedValue> {
    let label: String
    let value: AssociatedValue
}

public protocol Status {
    func associatedValue<AssociatedValue>(mathing pattern: (AssociatedValue) -> Self) -> AssociatedValue?
}

public extension Status {
    func associatedValue<AssociatedValue>(mathing pattern: (AssociatedValue) -> Self) -> AssociatedValue? {
        guard let decomposed: Case<AssociatedValue> = decompose(),
              let patternLabel = Mirror(reflecting: pattern(decomposed.value)).children.first?.label,
            decomposed.label == patternLabel
        else {
            return nil
        }
        return decomposed.value
    }
}

private extension Status {
    var label: String {
        return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
    func decompose<AssociatedValue>() -> Case<AssociatedValue>? {
       for case let (label?, value) in Mirror(reflecting: self).children {
           if let result = (value as? AssociatedValue) ?? (Mirror(reflecting: value).children.first?.value as? AssociatedValue) {
               return Case(label: label, value: result)
           }
       }
       return nil
   }
}

public extension Combine.Publisher where Output: Status {
    
    func `case`<ElementOfResult>(_ closure: @escaping (ElementOfResult) -> Output) -> Publishers.CompactMap<Self, ElementOfResult> {
        return Publishers.CompactMap(upstream: self, transform: {
            $0.associatedValue(mathing: closure)
        })
    }
    
    func `case`(_ output: Output) -> Publishers.Map<Publishers.Filter<Self>, Void> {
        return Publishers.Filter(upstream: self, isIncluded: {
            String(describing: $0) == String(describing: output)
        }).map({ _ in return () })
    }
    
    @available(*, deprecated, message: "Use the `case(Enum.case)` method instead. Simply change `case { Enum.case }` with `case(Enum.case)`")
    func `case`<ElementOfResult>(closure: @escaping () -> (ElementOfResult) -> Output) -> Publishers.CompactMap<Self, ElementOfResult> {
        return Publishers.CompactMap(upstream: self, transform: {
            $0.associatedValue(mathing: closure())
        })
    }
    
    @available(*, deprecated, message: "Use the `case(Enum.case)` method instead. Simply change `case { Enum.case }` with `case(Enum.case)`")
    func `case`(closure: @escaping () -> Output) -> Publishers.Filter<Self> {
        return Publishers.Filter(upstream: self, isIncluded: {
            String(describing: $0) == String(describing: closure())
        })
    }
}
