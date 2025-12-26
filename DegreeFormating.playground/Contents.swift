import UIKit
import CoreLocation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String {
    subscript(i: Int) -> Character? {
        guard i >= 0 && i < self.count else { return nil }
        return self[index(startIndex, offsetBy: i)]
    }
}

fileprivate func DecimalDegrees(degrees: CLLocationDegrees) -> String {
    let decimalDegrees = Double(degrees).rounded(toPlaces: 2)
    return "\(decimalDegrees)"
}

fileprivate func DegreesInDMS(degrees: CLLocationDegrees) -> String {
    let d = Int(degrees)
    let fractualMinutes = (degrees - Double(d)) * 60
    let m = Int(fractualMinutes)
    let s = Int((fractualMinutes - Double(m))*60)
    return "\(d)\u{00B0} \(m)' \(s)\""
}

fileprivate func DegreesInRaymarineFormat(degrees: CLLocationDegrees) -> String {
    let d = Int(degrees)
    let fractualMinutes = Double((degrees - Double(d)) * 60).rounded(toPlaces: 3)
    return "\(d)\u{00B0} \(fractualMinutes)'"
}

fileprivate func extractTenth(degrees: CLLocationDegrees) -> String {
    print("Degrees in tens: \(String(degrees))")
    let strDegrees = String(degrees)
    let periodIndex = strDegrees.firstIndex(of: ".")
    //NOTE: CLLocationsDegrees values ALWAYS contain a period
    if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > 1 {
        let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
        let tensIndex = strDegrees.index(strDegrees.startIndex, offsetBy: periodPosition + 1, limitedBy: strDegrees.endIndex)
        return String(strDegrees[tensIndex!])
    } else {
        return "0"
    }
}

fileprivate func extractHundredth(degrees: CLLocationDegrees) -> String {
    let strDegrees = String(degrees)
    let periodIndex = strDegrees.firstIndex(of: ".")
    //NOTE: CLLocationsDegrees values ALWAYS contain a period
    if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > 2 {
        let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
        let hundredsIndex = strDegrees.index(strDegrees.startIndex, offsetBy: periodPosition + 2, limitedBy: strDegrees.endIndex)
        return String(strDegrees[hundredsIndex!])
    } else {
        return "0"
    }
}

fileprivate func extractThousandth(degrees: CLLocationDegrees) -> String {
    let strDegrees = String(degrees)
    let periodIndex = strDegrees.firstIndex(of: ".")
    //NOTE: CLLocationsDegrees values ALWAYS contain a period
    if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > 3 {
        let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
        let thousandsIndex = strDegrees.index(strDegrees.startIndex, offsetBy: periodPosition + 3, limitedBy: strDegrees.endIndex)
        return String(strDegrees[thousandsIndex!])
    } else {
        return "0"
    }
}

var degrees: CLLocationDegrees = 37.8234
let strDegrees = String(Int(degrees)) + "."
+ extractTenth(degrees: degrees)
+ extractHundredth(degrees: degrees)
+ extractThousandth(degrees: degrees)
