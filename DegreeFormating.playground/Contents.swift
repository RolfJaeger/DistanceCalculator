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
    subscript(characterIndex: Int) -> Character {
        let index = self.index(self.startIndex, offsetBy: characterIndex)
        return self[index]
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

func extractDigitAtSpecifiedLocationAfterPeriod(degrees: CLLocationDegrees, position: Int) -> String {
    let degreesRounded = Double(degrees).rounded(toPlaces: 4)
    let strDegrees = String(degreesRounded)
    let periodIndex = strDegrees.firstIndex(of: ".")
    if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > position {
        let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
        return String(strDegrees[periodPosition + position])
    } else {
        return "0"
    }
}

fileprivate func updateDegreesFromDMS(degrees: Int, minutes: Int, seconds: Int) -> CLLocationDegrees {
    let decimalMinutes = Double(minutes)/60
    let decimalSeconds = Double(seconds)/60/60
    return CLLocationDegrees(Double(degrees) + decimalMinutes + decimalSeconds)
}

fileprivate func updateDegreesFromDMS(originalDegrees: CLLocationDegrees, degrees: Int, minutes: Int, seconds: Int) -> CLLocationDegrees {
    //First calculate the original degrees in seconds
    let originalDegreesInSeconds = originalDegrees * 3600.0
    print("Original Degrees in Seconds: \(originalDegreesInSeconds)")
    //Now calculate the new degrees in seconds
    let newDegreesInSeconds = Double(degrees) * 3600.0
    let newMinutesInSeconds = Double(minutes) * 60.0
    let newTotalInSeconds = newDegreesInSeconds + newMinutesInSeconds + Double(seconds)
    print("New Degrees in Seconds: \(newTotalInSeconds)")
    //Now calculate the difference in seconds
    let secondsToAddOrSubtract = (newTotalInSeconds - originalDegreesInSeconds).rounded()
    print("Delta between Original and New: \(secondsToAddOrSubtract) sec")
    let degreesAfterUpdate = originalDegrees + secondsToAddOrSubtract/3600.0
    return degreesAfterUpdate
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

private func testInitiazation() {
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

}

private func testUpdateDegreesFromDMS() {
    
    let locDegrees = 37.912999999999997
    let strLocDegrees = DegreesInDMS(degrees: locDegrees)
    print("Initial Degrees: \(locDegrees)")
    print("Initial DMS: \(strLocDegrees)")
    
    let initialPlusOneSecond = (locDegrees * 3600.0 + 1)/3600.0
    print("Initial Degrees plus 1 second: \(initialPlusOneSecond)")
    
    let degrees = 37
    let minutes = 54
    var seconds = 48
    
    var calculatedDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutes, seconds: seconds)
    print("Calculated Degrees: \(calculatedDegrees)")
    var strDegreesInDMS = DegreesInDMS(degrees: calculatedDegrees)
    print("In DMS Format: \(strDegreesInDMS)")
    //Now subtract a second
    seconds = 47
    calculatedDegrees = updateDegreesFromDMS(originalDegrees: calculatedDegrees, degrees: degrees, minutes: minutes, seconds: seconds)
    print("Degrees after subtracting 1 second: \(calculatedDegrees)")
    let diff = locDegrees - calculatedDegrees
    print("Difference: \(diff)")

}

//testUpdateDegreesFromDMS()
//testTenThousandth()

let degrees = 122.34957
print(degrees)
let tenth = extractDigitAtSpecifiedLocationAfterPeriod(degrees: degrees, position: 1)
let hundredth = extractDigitAtSpecifiedLocationAfterPeriod(degrees: degrees, position: 2)
let thousandth = extractDigitAtSpecifiedLocationAfterPeriod(degrees: degrees, position: 3)
let tenthousandth = extractDigitAtSpecifiedLocationAfterPeriod(degrees: degrees, position: 4)
let strDegrees = "\(Int(degrees)).\(tenth)\(hundredth)\(thousandth)\(tenthousandth)"
print(strDegrees)
