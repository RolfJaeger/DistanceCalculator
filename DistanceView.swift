//
//  DistanceView.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 12/18/25.
//

/*
TODO List:
 - Make sure that initial Location 1 is actual user location
 */

import SwiftUI
import CoreLocation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

struct DistanceView: View {
    @Binding var latLoc1: CLLocationDegrees
    @Binding var longLoc1: CLLocationDegrees
    @Binding var latLoc2: CLLocationDegrees
    @Binding var longLoc2: CLLocationDegrees
    
    @State var viewFormat: ViewFormat

    @State var loc1LatViewVisible = false
    @State var loc1LongViewVisible = false
    @State var loc2LatViewVisible = false
    @State var loc2LongViewVisible = false

    @State var NortSouthLoc1 = "N"
    @State var EastWestLoc1 = "E"
    @State var NortSouthLoc2 = "N"
    @State var EastWestLoc2 = "E"

    fileprivate func restoreToDefaultView() {
        hideKeyboard()
        loc1LatViewVisible = false
        loc1LongViewVisible = false
        loc2LatViewVisible = false
        loc2LongViewVisible = false
    }
    
    var body: some View {
        VStack {
            Text("Distance Calculator")
                .font(.title)
                .bold()
                .padding()
            MenuView
                .padding()
            Form {
                Section("Distance") {
                    DistanceView
                }
                Section("Location 1") {
                    Location1Details
                }
                Section("Location 2") {
                    Location2Details
                }
            }
            MinimizeButton
        }
    }
    
    fileprivate var MenuView: some View {
        HStack {
            Button(action: {
                hideKeyboard()
            }, label: {Image(systemName: "keyboard")})
            Text("|")
            Button(action: {
                switch viewFormat {
                case .DMS:
                    viewFormat = .Raymarine
                case .DDM:
                    viewFormat = .DMS
                default:
                    viewFormat = .DDM
                }
            }, label: {Text("Switch Display Format")})
        }
    }
    
    fileprivate var Location1Details_Rev0: some View {
        VStack {
            HStack {
                if !loc1LatViewVisible && !loc1LongViewVisible {
                    Text(NortSouthLoc1)
                    Text(DegreesToStringInSelectedFormat(degrees: latLoc1, viewFormat: viewFormat))
                        .onTapGesture {
                            loc1LatViewVisible.toggle()
                            loc1LongViewVisible = false
                            loc2LatViewVisible = false
                            loc2LongViewVisible = false
                        }
                    Text(" | ")
                    Text(EastWestLoc1)
                    Text(DegreesToStringInSelectedFormat(degrees: longLoc1, viewFormat: viewFormat))
                        .onTapGesture {
                            loc1LongViewVisible.toggle()
                            loc1LatViewVisible = false
                            loc2LatViewVisible = false
                            loc2LongViewVisible = false
                        }
                }
            }
            if loc1LatViewVisible {
                VStack {
                    HStack {
                        Text(NortSouthLoc1)
                            .onTapGesture {
                                NortSouthLoc1 = (NortSouthLoc1 == "N") ? "S" : "N"
                            }
                        Text(DegreesToStringInSelectedFormat(degrees: latLoc1, viewFormat: viewFormat))
                    }
                    .onTapGesture {
                        loc1LatViewVisible = false
                    }
                    DegreesEntryView(orientation: NortSouthLoc1, locDegrees: $latLoc1, viewFormat: $viewFormat)
                        .frame(height: 100)
                }
            }
            
            if loc1LongViewVisible {
                VStack {
                    HStack {
                        Text(EastWestLoc1)
                            .onTapGesture {
                                EastWestLoc1 = (EastWestLoc1 == "E") ? "W" : "E"
                            }
                        Text(DegreesToStringInSelectedFormat(degrees: longLoc1, viewFormat: viewFormat))
                    }
                    .onTapGesture {
                        loc1LongViewVisible = false
                    }
                    DegreesEntryView(orientation: EastWestLoc1, locDegrees: $longLoc1, viewFormat: $viewFormat)
                }
            }
        }
    }

    fileprivate var Loc1Minimized: some View {
        HStack {
            Text(NortSouthLoc1)
            Text(DegreesToStringInSelectedFormat(degrees: latLoc1, viewFormat: viewFormat))
                .onTapGesture {
                    loc1LatViewVisible.toggle()
                    loc1LongViewVisible = false
                    loc2LatViewVisible = false
                    loc2LongViewVisible = false
                }
            Text(" | ")
            Text(EastWestLoc1)
            Text(DegreesToStringInSelectedFormat(degrees: longLoc1, viewFormat: viewFormat))
                .onTapGesture {
                    loc1LongViewVisible.toggle()
                    loc1LatViewVisible = false
                    loc2LatViewVisible = false
                    loc2LongViewVisible = false
                }
        }
    }
    
    fileprivate var Location1Details: some View {
        VStack {
            HStack {
                if !loc1LatViewVisible && !loc1LongViewVisible {
                    Loc1Minimized
                }
            }
            if loc1LatViewVisible {
                VStack {
                    HStack {
                        Button(action: {
                            NortSouthLoc1 = (NortSouthLoc1 == "N") ? "S" : "N"
                        }, label: {
                            Text(NortSouthLoc1)
                        })
                        Text(DegreesToStringInSelectedFormat(degrees: latLoc1, viewFormat: viewFormat))
                            .onTapGesture {
                                loc1LatViewVisible = false
                            }
                    }
                    DegreesEntryView(orientation: NortSouthLoc1, locDegrees: $latLoc1, viewFormat: $viewFormat)
                        .frame(height: 100)
                }
            }
            
            if loc1LongViewVisible {
                VStack {
                    HStack {
                        Button(action: {
                            EastWestLoc1 = (EastWestLoc1 == "E") ? "W" : "E"
                        }, label: {
                            Text(EastWestLoc1)
                        })
                        Text(DegreesToStringInSelectedFormat(degrees: longLoc1, viewFormat: viewFormat))
                            .onTapGesture {
                                loc1LongViewVisible = false
                            }
                    }
                    DegreesEntryView(orientation: EastWestLoc1, locDegrees: $longLoc1, viewFormat: $viewFormat)
                }
            }
        }
    }

    fileprivate var Location2Details: some View {
        VStack {
            HStack {
                if !loc2LatViewVisible && !loc2LongViewVisible {
                    Text(NortSouthLoc2)
                    Text(DegreesToStringInSelectedFormat(degrees: latLoc2, viewFormat: viewFormat))
                        .onTapGesture {
                            loc2LatViewVisible.toggle()
                            loc2LongViewVisible = false
                            loc1LatViewVisible = false
                            loc1LongViewVisible = false
                        }
                    Text(" | ")
                    Text(EastWestLoc2)
                    Text(DegreesToStringInSelectedFormat(degrees: longLoc2, viewFormat: viewFormat))
                        .onTapGesture {
                            loc2LongViewVisible.toggle()
                            loc2LatViewVisible = false
                            loc1LatViewVisible = false
                            loc1LongViewVisible = false
                        }
                }
            }
            if loc2LatViewVisible {
                VStack {
                    HStack {
                        Button(action: {
                            NortSouthLoc2 = (NortSouthLoc2 == "N") ? "S" : "N"
                        }, label: {
                            Text(NortSouthLoc2)
                        })
                        Text(DegreesToStringInSelectedFormat(degrees: latLoc2, viewFormat: viewFormat))
                            .onTapGesture {
                                loc2LatViewVisible = false
                            }
                    }
                    DegreesEntryView(orientation: NortSouthLoc2, locDegrees: $latLoc2, viewFormat: $viewFormat)
                }
            }
            if loc2LongViewVisible {
                VStack {
                    HStack {
                        Button(action: {
                            EastWestLoc2 = (EastWestLoc2 == "E") ? "W" : "E"
                        }, label: {
                            Text(EastWestLoc2)
                        })
                        Text(DegreesToStringInSelectedFormat(degrees: longLoc2, viewFormat: viewFormat))
                            .onTapGesture {
                                loc2LongViewVisible = false
                            }
                    }
                    DegreesEntryView(orientation: EastWestLoc2, locDegrees: $longLoc2, viewFormat: $viewFormat)
                }
            }
        }
    }

    fileprivate var DistanceView: some View {
        HStack {
            Text(CalculateDistance(latLoc1: latLoc1, longLoc1: longLoc1, latLoc2: latLoc2, longLoc2: longLoc2))
            Text("nm")
        }
        .font(.title)
    }

    fileprivate var MinimizeButton: some View {
        VStack {
            if loc1LatViewVisible || loc1LongViewVisible || loc2LatViewVisible || loc2LongViewVisible {
                Button(action: {
                    loc1LatViewVisible = false
                    loc1LongViewVisible = false
                    loc2LatViewVisible = false
                    loc2LongViewVisible = false
                }, label: {
                    Text("Minimize")
                })
            }
        }
    }
    
    fileprivate func CalculateDistance(
        latLoc1: CLLocationDegrees,
        longLoc1: CLLocationDegrees,
        latLoc2: CLLocationDegrees,
        longLoc2: CLLocationDegrees) -> String {
            
        let latLoc1WithSign = NortSouthLoc1 == "S" ? -latLoc1 : latLoc1
        
        let latLoc2WithSign = NortSouthLoc2 == "S" ? -latLoc2 : latLoc2
        
        let longLoc1WithSign = EastWestLoc1 == "W" ? -longLoc1 : longLoc1
            
        let longLoc2WithSign = EastWestLoc2 == "W" ? -longLoc2 : longLoc2

        let p1 = CLLocationCoordinate2D(latitude: latLoc1WithSign, longitude: longLoc1WithSign)
        let p2 = CLLocationCoordinate2D(latitude: latLoc2WithSign, longitude: longLoc2WithSign)

        let location1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
        let location2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
        let nauticalMilesPerKilometer = 0.539957
        let strDistance = String(format: "%.3f", location2.distance(from: location1) * nauticalMilesPerKilometer / 1000)
        return strDistance
    }
    
    fileprivate func LatLongToString(lat: CLLocationDegrees, long: CLLocationDegrees, viewFormat: ViewFormat) -> String {
        var strLat = lat >= 0.0 ? "N" : "S"
        switch viewFormat {
        case .DMS:
            strLat = strLat + DegreesInDMS(degrees: lat)
        case .DDM:
            strLat = strLat + DecimalDegrees(degrees: lat)
        case .Raymarine:
            strLat = strLat + DegreesInRaymarineFormat(degrees: lat)
        }
        var strLong = long >= 0.0 ? "E" : "W"
        switch viewFormat {
        case .DMS:
            strLong = strLong + DegreesInDMS(degrees: long)
        case .DDM:
            strLong = strLong + DecimalDegrees(degrees: long)
        case .Raymarine:
            strLong = strLong + DegreesInRaymarineFormat(degrees: long)
        }
        let strLatLong = strLat + " | " + strLong
        return strLatLong
    }

    fileprivate func DegreesToStringInSelectedFormat(degrees: CLLocationDegrees, viewFormat: ViewFormat) -> String {
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

    fileprivate func DegreesToString(degrees: CLLocationDegrees) -> String {
        return "\(degrees)"
    }
    
    fileprivate func DecimalDegrees(degrees: CLLocationDegrees) -> String {
        let decimalDegrees = Double(degrees).rounded(toPlaces: 2)
        return "\(decimalDegrees)\u{00B0}"
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

    
}

#Preview {
    @Previewable @State var latLoc1: CLLocationDegrees = CLLocationDegrees(floatLiteral: 0.0)
    @Previewable @State var longaLoc1: CLLocationDegrees = CLLocationDegrees(floatLiteral: 0.0)
    @Previewable @State var latLoc2: CLLocationDegrees = CLLocationDegrees(floatLiteral: 0.0)
    @Previewable @State var longLoc2: CLLocationDegrees = CLLocationDegrees(floatLiteral: 0.0)
    
    var viewFormat: ViewFormat = .DDM

    return DistanceView(latLoc1: $latLoc1, longLoc1: $longLoc2, latLoc2: $latLoc2, longLoc2: $longLoc2, viewFormat: viewFormat)
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

