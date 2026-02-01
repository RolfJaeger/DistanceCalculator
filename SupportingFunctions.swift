//
//  Misc.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 12/29/25.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

//*******************
//Fonts for iPad only
//*******************
let titleFont: CGFloat = 60
let subtitleFont: CGFloat = 30
let buttonFont: CGFloat = 35
let dataFont: CGFloat = 45
let hintFont:CGFloat = 30

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

struct Location: Identifiable, Hashable, Equatable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var name: String
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.name == rhs.name
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

struct CodableLocation: Codable, Hashable {
    var coordinate: CodableCoordinate
    var name: String
    static func ==(lhs: CodableLocation, rhs: CodableLocation) -> Bool {
        return lhs.name == rhs.name
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

struct CodableCoordinate: Codable {
    var latitude: CLLocationDegrees // Typealias for Double
    var longitude: CLLocationDegrees

    // Initialize from CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    // Computed property to convert back to the original type
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum ViewName: String {
    case Loc1Lat
    case Loc1Long
    case Loc2Lat
    case Loc2Long
}

enum PlusMinusTarget {
    case DEGREES
    case MINUTES
    case SECONDS
    case TENTH
    case HUNDREDTH
    case THOUSANDTH
    case TENTHOUSANDTH
}

enum DecimalDegrees_PlusMinusTarget {
    case DEGREES
    case TENTH
    case HUNDREDTH
    case THOUSANDTH
    case TENTHOUSANDTH
}

enum Raymarine_PlusMinusTarget {
    case DEGREES
    case MINUTES
    case TENTH
    case HUNDREDTH
    case THOUSANDTH
}

enum DMS_PlusMinusTarget {
    case DEGREES
    case MINUTES
    case SECONDS
}

enum ViewFormat: String {
    case DMS = "Degrees-Mins-Secs"
    case DDM = "Decimal Degrees"
    case Raymarine = "Raymarine"
}

enum PickerName: String {
    case Degrees
    case Minutes
    case Tenth
    case Hundredth
    case Thousandth
    case TenThousandth
    case Seconds
}

enum DecimalDegrees_PickerName: String {
    case Degrees
    case Tenth
    case Hundredth
    case Thousandth
    case TenThousandth
}


enum DMS_PickerName: String {
    case Degrees
    case Minutes
    case Seconds
}

enum Raymarine_PickerName: String {
    case Degrees
    case Minutes
    case Tenth
    case Hundredth
    case Thousandth
}

func CalculateDistance(
    Loc1: Location,
    Loc2: Location
) -> String {

    let p1 = CLLocationCoordinate2D(latitude: Loc1.coordinate.latitude, longitude: Loc1.coordinate.longitude)
    let p2 = CLLocationCoordinate2D(latitude: Loc2.coordinate.latitude, longitude: Loc2.coordinate.longitude)

    let location1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
    let location2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
    let nauticalMilesPerKilometer = 0.539957
    let strDistance = String(format: "%.4f", location2.distance(from: location1) * nauticalMilesPerKilometer / 1000)
    return strDistance
}

func DegreesToStringInSelectedFormat(degrees: CLLocationDegrees, viewFormat: ViewFormat) -> String {
    var strDegrees: String
    switch viewFormat {
    case .DMS:
        strDegrees = DegreesInDMS(degrees: degrees)
    case .DDM:
        strDegrees = DecimalDegrees(degrees: degrees)
    case .Raymarine:
        strDegrees = DegreesInRaymarineFormat(degrees: degrees)
    }
    return strDegrees
}

func DegreesInDMS(degrees: CLLocationDegrees) -> String {
    let degreesWithoutSign = degrees < 0 ? -degrees : degrees
    var d = Int(degreesWithoutSign)
    var fractualMinutes = (degreesWithoutSign - Double(d)) * 60
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
    let s = Int(doubleSeconds.rounded(toPlaces: 0))
    return "\(d)\u{00B0} \(m)' \(s)\""
}

func DecimalDegrees(degrees: CLLocationDegrees) -> String {
    var decimalDegrees = Double(degrees).rounded(toPlaces: 4)
    if decimalDegrees < 0 {
        decimalDegrees = -decimalDegrees
    }
    return "\(decimalDegrees)\u{00B0}"
}


func DegreesInRaymarineFormat(degrees: CLLocationDegrees) -> String {
    var d = Int(degrees)
    var fractualMinutes = Double((degrees - Double(d)) * 60).rounded(toPlaces: 3)
    if degrees < 0 {
        d = -d
        if fractualMinutes < 0 {
            fractualMinutes = -fractualMinutes
        }
    }
    return "\(d)\u{00B0} \(fractualMinutes)'"
}



