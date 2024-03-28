@testable import ARCoreKit
import XCTest

final class DoubleExtensionTests: XCTestCase {
    
    func test_string() {
        let double = 12.34567
        
        XCTAssert(double.string(2) == "12.34")
        XCTAssert(double.string(3) == "12.345")
        XCTAssert(double.string(2, round: true) == "12.35")
    }
    
}
