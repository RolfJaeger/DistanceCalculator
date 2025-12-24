import UIKit
import CoreLocation

var minutes = "0"
var seconds = "0"

func trunc(strDegrees: String) -> String {
    guard let fltDegrees = Float(strDegrees) else {
        return "0"
    }
    let intDegrees = Int(fltDegrees)
    return String(intDegrees)
}

fileprivate func CalcMinutesAndSecondsFromDecimalDegrees(degrees: String) {
    let absDegrees = degrees.replacingOccurrences(of: "-", with: "")
    guard let dblDegrees = Double(absDegrees) else {
        minutes = "0"
        return
    }
    let intDegrees = Int(dblDegrees)
    let fractionalMinutes = (dblDegrees - Double(intDegrees)) * 60
    let intMinutes = Int(fractionalMinutes)
    minutes = String(intMinutes)
    let dblSeconds = (fractionalMinutes - Double(intMinutes)) * 60
    let intSeconds = Int(dblSeconds)
    seconds = String(intSeconds)
}

fileprivate func CalculateDecimalDegrees(strDegrees: String, strDecimalMinutes: String) -> CLLocationDegrees {
    guard let fltDegrees = Float(strDegrees) else {
        return 0.0
    }
    guard let fltFractionalMinutes = Float(strDecimalMinutes) else {
        return 0.0
    }
    var strDecimalDegrees = "0.0"
    if fltDegrees < 0 {
        strDecimalDegrees = String(format: "%.3f", fltDegrees - fltFractionalMinutes/60)
    } else {
        strDecimalDegrees = String(format: "%.3f", fltDegrees + fltFractionalMinutes/60)
    }
    let decimalDegrees = Double(strDecimalDegrees)
    return CLLocationDegrees(decimalDegrees!)
}

let strDegrees = "-122.55"
CalcMinutesAndSecondsFromDecimalDegrees(degrees: strDegrees)
print("Minutes: \(minutes)")
print("Seconds: \(seconds)")

let intDegrees = trunc(strDegrees: strDegrees)
let strDecimalMinutes = "30"
let strDecimalDegrees = CalculateDecimalDegrees(strDegrees: strDegrees, strDecimalMinutes: strDecimalMinutes)

let nauticalMilesPerKilometer = 0.539957

let p1 = CLLocationCoordinate2D(latitude: 37.0, longitude: 0.0)
let p2 = CLLocationCoordinate2D(latitude: 38.0, longitude: 0.0)

let location1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
let location2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)

let distance = String(format: "%.3f", location2.distance(from: location1) * nauticalMilesPerKilometer / 1000)
