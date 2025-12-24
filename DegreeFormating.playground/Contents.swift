import UIKit
import CoreLocation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
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

fileprivate func tens(degrees: CLLocationDegrees) -> String {
    let intDegrees = Int(degrees)
    if Double(intDegrees) - degrees != 0 {
        var remainder = degrees - Double(intDegrees)
        return String(Int(remainder * 10))
    } else {
        return ""
    }
}

fileprivate func hundreds(degrees: CLLocationDegrees) -> String {
    /*
     This isn't working as intended because of rounding errors.
     Try to work with string positions instead.
     Created a method like DigitAtPosition(strDegrees: String, iPos: Int)
     DigitAtPosition(strDegrees: "120.15", iPos: 2) would return "5"
     */
    let intDegrees = Int(degrees)
    if Double(intDegrees) - degrees != 0 {
        var remainder = 10 * (degrees - Double(intDegrees))
        let tens = Int(remainder)
        if remainder - Double(tens) != 0 {
            remainder = 10*remainder - Double(tens)
            return String(Int(remainder * 10))
        } else {
            return ""
        }
    } else {
        return ""
    }
}

var degrees: CLLocationDegrees = 120.1
print("Decimal Degrees: \(DecimalDegrees(degrees: degrees))")
print("DMS Format: \(DegreesInDMS(degrees: degrees))")
print("Degrees in Raymarine Format: \(DegreesInRaymarineFormat(degrees: degrees))")

var strDegrees: String

strDegrees = String(Int(degrees))
var remainder = degrees - Double(Int(strDegrees)!)
let tens = Int(remainder * 10)
let strTens = tens(degrees: degrees)
let strHundreds = hundreds(degrees: degrees)
remainder = 10*remainder - Double(tens)
let hundreds = Int(remainder * 10)
remainder = 10*remainder - Double(hundreds)
let thousands = Int(remainder * 10)
strDegrees = "\(strDegrees).\(tens)\(hundreds)\(thousands)"
