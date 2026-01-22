//
//  Misc.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 12/29/25.
//

import Foundation
import SwiftUI
import CoreLocation

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

struct Location: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var name: String
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
