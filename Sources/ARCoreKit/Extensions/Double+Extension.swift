import Foundation

public extension Double {
    func string(_ decimals: Int, round: Bool = false) -> String {
        if round {
            return String(format: "%.\(decimals)f", self)
        } else {
            return self.fractionDigits(min: decimals, max: decimals, roundingMode: .down)
        }
    }
}

public extension FloatingPoint {
    func fractionDigits(min: Int = 2, max: Int = 2, roundingMode: NumberFormatter.RoundingMode = .halfEven, decimalSeparator: String = ".") -> String {
        let format = NumberFormatter()
        format.minimumFractionDigits = min
        format.maximumFractionDigits = max
        format.roundingMode = roundingMode
        format.numberStyle = .decimal
        format.decimalSeparator = decimalSeparator
        format.usesGroupingSeparator = false
        return format.string(for: self) ?? ""
    }
}
