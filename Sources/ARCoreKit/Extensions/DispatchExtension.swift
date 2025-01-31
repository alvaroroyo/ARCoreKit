import Foundation

public extension DispatchQueue {
    
    static func mainAfter(_ delay: Double, _ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: completion)
    }
    
}
