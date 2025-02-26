import Foundation

public extension Array {
    func safeGet(_ index: Int) -> Element? {
        guard index <= self.count - 1 else { return nil }
        return self[index]
    }
}

public extension Array where Element: Comparable {
    mutating func appendIfNotExists(_ element: Element) {
        guard !self.contains(where: { $0 == element }) else { return }
        self.append(element)
    }
}

public extension Array where Element : Equatable {
  subscript(safe bounds: Range<Int>) -> Array<Element> {
    if bounds.lowerBound > count { return [] }
    let lower = Swift.max(0, bounds.lowerBound)
    let upper = Swift.max(0, Swift.min(count, bounds.upperBound))
    return Array(self[lower..<upper])
  }
}
