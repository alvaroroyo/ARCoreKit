import Foundation

public extension String {
    
    var replaceSpecial: String {
        let specialChars = [
            "á": "a",
            "é": "e",
            "í": "i",
            "ó": "o",
            "ú": "u"
        ]
        return self.reduce(into: "") { partialResult, char in
            let str = String(char)
            partialResult += specialChars[str] ?? str
        }
    }
    
    var valueOrNil: String? {
        guard !self.isEmpty else { return nil }
        return self
    }
    
}
