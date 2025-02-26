import Foundation

public struct CacheManager {
    
    let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    public init() {}
    
    public func add(_ data: Data, withKey key: String) {
        do {
            let key = replaceKey(key)
            try data.write(to: cacheUrl.appendingPathComponent(key))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func getData(withKey key: String) -> Data? {
        do {
            let key = replaceKey(key)
            return try Data(contentsOf: cacheUrl.appendingPathComponent(key))
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func replaceKey(_ key: String) -> String {
        key.replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "_", with: "")
        
        
    }
}
