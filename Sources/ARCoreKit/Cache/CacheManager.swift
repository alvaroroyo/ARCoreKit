import Foundation

public struct CacheManager {
    
    let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    public init() {}
    
    public func add(_ data: Data, withKey key: String) {
        try? data.write(to: cacheUrl.appendingPathComponent(key))
    }
    
    public func getData(withKey key: String) -> Data? {
        try? Data(contentsOf: cacheUrl.appendingPathComponent(key))
    }
}
