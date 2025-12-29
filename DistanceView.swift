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

enum ViewName: String {
    case Loc1Lat
    case Loc1Long
    case Loc2Lat
    case Loc2Long
}

struct DistanceView: View {
    
    @ObservedObject var locationManager = LocationManager()
    
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

    @State var hintVisible = true
    
    var txtSwitchFormat: String {
        switch viewFormat {
        case .DMS:
            return "Switch to Raymarine Format"
        case .DDM:
            return "Switch to Deg Min Sec"
        case .Raymarine:
            return "Switch to Decimal Degress"
        }
    }
    
    var body: some View {
        VStack {
            Text("Distance Calculator")
                .font(.title)
                .bold()
                .padding()
            FormatView
                .padding(.bottom, 10)
            Text("Distance")
                .font(.title2)
                .bold()
                .padding(.bottom, 0)
            DistanceView
            Text("Location 1")
                .font(.title2)
                .bold()
                .padding(.top, 10)
                .padding(.bottom, 5)
            Location1Details
            Text("Location 2")
                .font(.title2)
                .bold()
                .padding(.top, 10)
                .padding(.bottom, 5)
            Location2Details
            
            HintView
            Spacer()
        }
        .onAppear {
            if let userLocation = locationManager.lastKnownLocation {
                latLoc1 = userLocation.latitude
                latLoc1 = Double(latLoc1).rounded(toPlaces: 3)
                if latLoc1 < 0 {
                    latLoc1 = -latLoc1
                    NortSouthLoc1 = "S"
                }
                longLoc1 = userLocation.longitude
                longLoc1 = Double(longLoc1).rounded(toPlaces: 3)
                if longLoc1 < 0 {
                    longLoc1 = -longLoc1
                    EastWestLoc1 = "W"
                }
                
                latLoc2 = latLoc1
                NortSouthLoc2 = NortSouthLoc1
                
                longLoc2 = longLoc1
                EastWestLoc2 = EastWestLoc1
                
            } else {
                latLoc1 = 0.0
                NortSouthLoc1 = "N"
                longLoc1 = 0.0
                EastWestLoc1 = "W"
                
                latLoc2 = 0.0
                NortSouthLoc1 = "N"
                longLoc2 = 0.0
                EastWestLoc1 = "W"
                
                hintVisible = false
            }
        }
    }
    
    fileprivate var HintView: some View {
        VStack {
            if !loc1LatViewVisible && !loc1LongViewVisible && !loc2LatViewVisible && !loc2LongViewVisible {
                if hintVisible {
                    Text("Initially your location is shown.")
                        .padding(.top, 20)
                    Text("Tap coordinates to modify.")
                }
            }
        }
    }
    
    fileprivate var FormatView: some View {
        VStack {
            VStack {
                Text("Location Format")
                    .bold()
                switch viewFormat {
                case .DMS:
                    Text("Degrees | Minutes | Seconds")
                case .DDM:
                    Text("Decimal Degrees")
                case .Raymarine:
                    Text("Degrees | Decimal Minutes")
                }
            }
            Button(action: {
                switch viewFormat {
                case .DMS:
                    viewFormat = .Raymarine
                case .DDM:
                    viewFormat = .DMS
                case .Raymarine:
                    viewFormat = .DDM
                }
            }, label: {Text(txtSwitchFormat)})
            .buttonStyle(.bordered)
        }
    }
    
    fileprivate var Loc1Minimized: some View {
        HStack {
            Spacer()
            Text(NortSouthLoc1)
            Text(DegreesToStringInSelectedFormat(degrees: latLoc1, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc1Lat)
                }
            Text(" | ")
            Text(EastWestLoc1)
            Text(DegreesToStringInSelectedFormat(degrees: longLoc1, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc1Long)
                    
                }
            Spacer()
        }
        .font(.title2)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    fileprivate var Loc1LatExpanded: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    NortSouthLoc1 = (NortSouthLoc1 == "N") ? "S" : "N"
                }, label: {
                    Text("Hemisphere")
                })
                .buttonStyle(.bordered)
                Text(" | ")
                MinimizeButton
                Spacer()
            }
            HStack {
                Spacer()
                Text(NortSouthLoc1)
                Text(DegreesToStringInSelectedFormat(degrees: latLoc1, viewFormat: viewFormat))
                /*
                 .onTapGesture {
                 loc1LatViewVisible = false
                 }
                 */
                Spacer()
            }
            .font(.title)
            DegreesEntryView(orientation: NortSouthLoc1, locDegrees: $latLoc1, viewFormat: $viewFormat)
                .frame(height: 150)
        }
        //.containerRelativeFrame(.horizontal)
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    
    fileprivate var Loc1LongExpanded: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    EastWestLoc1 = (EastWestLoc1 == "E") ? "W" : "E"
                }, label: {
                    Text("Hemisphere")
                })
                .buttonStyle(.bordered)
                Text(" | ")
                MinimizeButton
                Spacer()
            }
            HStack {
                Spacer()
                Text(EastWestLoc1)
                Text(DegreesToStringInSelectedFormat(degrees: longLoc1, viewFormat: viewFormat))
                    .onTapGesture {
                        loc1LongViewVisible = false
                    }
                Spacer()
            }
            .font(.title)
            DegreesEntryView(orientation: EastWestLoc1, locDegrees: $longLoc1, viewFormat: $viewFormat)
                .frame(height: 150)
        }
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    
    fileprivate var Location1Details: some View {
        VStack {
            HStack {
                if !loc1LatViewVisible && !loc1LongViewVisible {
                    Loc1Minimized
                }
            }
            if loc1LatViewVisible {
                Loc1LatExpanded
            }
            
            if loc1LongViewVisible {
                Loc1LongExpanded
            }
        }
    }

    fileprivate var Loc2Minimized: some View {
        HStack {
            Spacer()
            Text(NortSouthLoc2)
            Text(DegreesToStringInSelectedFormat(degrees: latLoc2, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc2Lat)
                }
            Text(" | ")
            Text(EastWestLoc2)
            Text(DegreesToStringInSelectedFormat(degrees: longLoc2, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc2Long)
                }
            Spacer()
        }
        .font(.title2)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    fileprivate var Loc2LatExpanded: some View {
        VStack {
            HStack {
                Button(action: {
                    NortSouthLoc2 = (NortSouthLoc2 == "N") ? "S" : "N"
                }, label: {
                    Text("Hemisphere")
                })
                .buttonStyle(.bordered)
                Text(" | ")
                MinimizeButton
            }
            HStack {
                Text(NortSouthLoc2)
                Text(DegreesToStringInSelectedFormat(degrees: latLoc2, viewFormat: viewFormat))
                    .onTapGesture {
                        loc2LatViewVisible = false
                    }
            }
            .font(.title)
            DegreesEntryView(orientation: NortSouthLoc2, locDegrees: $latLoc2, viewFormat: $viewFormat)
                .frame(height: 150)
        }
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }

    fileprivate var Loc2LongExpanded: some View {
        VStack {
            HStack {
                Button(action: {
                    EastWestLoc2 = (EastWestLoc2 == "E") ? "W" : "E"
                }, label: {
                    Text("Hemisphere")
                })
                .buttonStyle(.bordered)
                Text(" | ")
                MinimizeButton
            }
            HStack {
                Text(EastWestLoc2)
                Text(DegreesToStringInSelectedFormat(degrees: longLoc2, viewFormat: viewFormat))
                    .onTapGesture {
                        loc2LongViewVisible = false
                    }
            }
            .font(.title)
            DegreesEntryView(orientation: EastWestLoc2, locDegrees: $longLoc2, viewFormat: $viewFormat)
                .frame(height: 150)
        }
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }

    fileprivate var Location2Details: some View {
        VStack {
            HStack {
                if !loc2LatViewVisible && !loc2LongViewVisible {
                    Loc2Minimized
                }
            }
            if loc2LatViewVisible {
                Loc2LatExpanded
            }
            if loc2LongViewVisible {
                Loc2LongExpanded
            }
        }
    }

    fileprivate var DistanceView: some View {
        HStack {
            Spacer()
            Text(CalculateDistance(latLoc1: latLoc1, longLoc1: longLoc1, latLoc2: latLoc2, longLoc2: longLoc2))
            Text("nm")
            Spacer()
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
                .buttonStyle(.bordered)
            }
        }
    }
    
    fileprivate func SetViewVisibility(viewName: ViewName) {
        loc1LatViewVisible = false
        loc1LongViewVisible = false
        loc2LatViewVisible = false
        loc2LongViewVisible = false
        switch viewName {
        case .Loc1Lat:
            loc1LatViewVisible.toggle()
        case .Loc1Long:
            loc1LongViewVisible.toggle()
        case .Loc2Lat:
            loc2LatViewVisible.toggle()
        case .Loc2Long:
            loc2LongViewVisible.toggle()
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
        let strDistance = String(format: "%.4f", location2.distance(from: location1) * nauticalMilesPerKilometer / 1000)
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
        let decimalDegrees = Double(degrees).rounded(toPlaces: 3)
        return "\(decimalDegrees)\u{00B0}"
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

    fileprivate func DegreesInRaymarineFormat(degrees: CLLocationDegrees) -> String {
        let d = Int(degrees)
        let fractualMinutes = Double((degrees - Double(d)) * 60).rounded(toPlaces: 4)
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

