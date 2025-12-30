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

fileprivate func DegreesInRaymarineFormat(degrees: CLLocationDegrees) -> String {
    let d = Int(degrees)
    let fractualMinutes = Double((degrees - Double(d)) * 60).rounded(toPlaces: 3)
    return "\(d)\u{00B0} \(fractualMinutes)'"
}

fileprivate func extractTenth(degrees: CLLocationDegrees) -> String {
    //print("Degrees in extractTenth: \(String(degrees))")
    let degreesRounded = Double(degrees).rounded(toPlaces: 3)
    let strDegrees = String(degreesRounded)
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
    let degreesRounded = Double(degrees).rounded(toPlaces: 3)
    let strDegrees = String(degreesRounded)
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
    let degreesRounded = Double(degrees).rounded(toPlaces: 3)
    let strDegrees = String(degreesRounded)
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

fileprivate func updateDegreesFromDMS(degrees: Int, minutes: Int, seconds: Int) -> CLLocationDegrees {
    let decimalMinutes = Double(minutes)/60
    let decimalSeconds = Double(seconds)/60/60
    return CLLocationDegrees(Double(degrees) + decimalMinutes + decimalSeconds)
}

fileprivate func DegreesInDMS(degrees: CLLocationDegrees) -> String {
    var d = Int(degrees)
    var fractualMinutes = (degrees - Double(d)) * 60
    if fractualMinutes == 60 {
        d += 1
        fractualMinutes = 0
    }
    var m = Int(fractualMinutes)
    var doubleSeconds = Double((fractualMinutes - Double(m))*60).rounded(toPlaces: 0)
    if doubleSeconds == 60 {
        m += 1
        doubleSeconds = 0
    }
    let s = Int(doubleSeconds)
    return "\(d)\u{00B0} \(m)' \(s)\""
}

/*
let degrees = 122
let minutes = 20
let seconds = 59

var calculatedDegrees = updateDegreesFromDMS(degrees: degrees, minutes: minutes, seconds: seconds)
var strDegreesInDMS = DegreesInDMS(degrees: calculatedDegrees)

calculatedDegrees = 122.35
strDegreesInDMS = DegreesInDMS(degrees: calculatedDegrees)
*/

/*
var degrees: CLLocationDegrees = 54.799999
let degreesRounded = Double(degrees).rounded(toPlaces: 3)
let test = degrees.rounded()
print(degreesRounded)
let strDegrees = String(Int(degreesRounded)) + "."
+ extractTenth(degrees: degrees)
+ extractHundredth(degrees: degrees)
+ extractThousandth(degrees: degrees)
print(strDegrees)
*/

var degrees = 122
let decimalDegrees = 122.34998333333333
var decimalMinutes = (decimalDegrees - Double(degrees)) * 60
if decimalMinutes == 60 {
    degrees += 1
    decimalMinutes = 0
}
let minutesInDecimalFormat = Double(decimalMinutes)
var minutes = Int(decimalMinutes.rounded(toPlaces: 3))
let decimalSeconds = Int(((minutesInDecimalFormat - Double(minutes))*60).rounded())
var seconds = Int(decimalSeconds)
if seconds == 60 {
   minutes += 1
   seconds = 0
}

let strDMS = DegreesInDMS(degrees: decimalDegrees)
print("In Distance View: \(strDMS)")
let calculatedDMS = "\(degrees)\u{00B0} \(minutes)' \(seconds)\""
print("In DegreesEntryView: \(calculatedDMS)")
