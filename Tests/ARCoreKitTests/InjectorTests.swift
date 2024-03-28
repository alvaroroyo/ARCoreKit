import XCTest
@testable import ARCoreKit

final class InjectorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_unique() {
        CoreServiceLocator.shared.add {
            Register(RegisterTestProtocol.self, .unique) {
                RegisterTest()
            }
        }
        
        @Inject var register: RegisterTestProtocol
        @Inject var otherRegister: RegisterTestProtocol
        
        XCTAssert(register === otherRegister)
    }
    
    func test_new() {
        CoreServiceLocator.shared.add {
            Register(RegisterTestProtocol.self, .new) {
                RegisterTest()
            }
        }
        
        @Inject var register: RegisterTestProtocol
        @Inject var otherRegister: RegisterTestProtocol
        
        XCTAssertFalse(register === otherRegister)
    }
    
    func test_multipleRegister() {
        CoreServiceLocator.shared.add {
            Register(RegisterTestProtocol.self) { RegisterTest() }
            Register(RegisterTestOtherProtocol.self) { RegisterTestOther() }
        }
        
        @Inject var register: RegisterTestProtocol
        @Inject var registerOther: RegisterTestOtherProtocol
        
        XCTAssert(register is RegisterTest)
        XCTAssert(registerOther is RegisterTestOther)
    }
}

protocol RegisterTestProtocol: AnyObject {
    func getString() -> String
}

protocol RegisterTestOtherProtocol: RegisterTestProtocol {}

extension InjectorTests {
    class RegisterTest: RegisterTestProtocol {
        let id = UUID().uuidString
        func getString() -> String { id }
    }
    
    class RegisterTestOther: RegisterTestOtherProtocol {
        let id = UUID().uuidString
        func getString() -> String { id }
    }
}
