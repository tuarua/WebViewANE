import Foundation
public extension URL {
    init?(safe: String) {
        if let clean = safe.components(separatedBy: "file://").last,
            let final = clean.removingPercentEncoding {
            self.init(fileURLWithPath: final)
        } else {
            return nil
        }
    }
}
