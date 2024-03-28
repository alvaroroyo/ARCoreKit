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
