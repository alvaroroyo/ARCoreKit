import Foundation

public extension [String: Any] {
    func object<T: Codable>() -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
