@testable import ARCoreKit
import XCTest

final class ArrayExtensionTests: XCTestCase {
    
    func test_safeGet() {
        let array = [1, 2, 3, 4]
        
        XCTAssertNotNil(array.safeGet(2))
        XCTAssertNil(array.safeGet(10))
    }
    
    func test_appendIfNotExists() {
        var array = [1, 2, 3]
        
        array.appendIfNotExists(4)
        
        XCTAssert(array.contains(where: { $0 == 4 }))
        
        array.appendIfNotExists(1)
        
        XCTAssert(array.last != 1)
    }
    
}

