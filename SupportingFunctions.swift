//
//  Misc.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 12/29/25.
//

import Foundation
import SwiftUI

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

