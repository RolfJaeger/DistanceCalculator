//
//  DistanceView_Rev0.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 9/1/25.
//

/*
import SwiftUI
import CoreLocation

struct DistanceView_Original: View {

    @Binding var latLoc1: CLLocationDegrees
    @Binding var longLoc1: CLLocationDegrees
    @Binding var latLoc2: CLLocationDegrees
    @Binding var longLoc2: CLLocationDegrees
    //@State var showDecimalDegrees: Bool
    @State var viewFormat: ViewFormat

    var body: some View {
        Form {
            Section("Location 1") {
                VStack {
                    Text("Latitude:")
                        .bold()
                        .font(.headline)
                    DegreesEntryView(locDegrees: $latLoc1, viewFormat: $viewFormat)
                    VStack {
                        Text("Longitude:")
                            .bold()
                            .font(.headline)
                        DegreesEntryView(locDegrees: $longLoc1, viewFormat: $viewFormat)
                    }
                    .padding(.top, 0)
                }
            }
            Section("Location 2") {
                VStack {
                    VStack {
                        Text("Latitude:")
                            .bold()
                            .font(.headline)
                        DegreesEntryView(locDegrees: $latLoc2, viewFormat: $viewFormat)
                            .padding(.top, 10)
                    }
                    VStack {
                        Text("Longitude:")
                            .bold()
                            .font(.headline)
                        DegreesEntryView(locDegrees: $longLoc2, viewFormat: $viewFormat)
                    }
                    .padding(.top, 0)
                }
            }
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
            Section("Distance") {
                HStack {
                    Text(CalculateDistance(latLoc1: latLoc1, longLoc1:longLoc1, latLoc2: latLoc2, longLoc2: longLoc2))
                    Text("nm")
                }
                .font(.title)
            }
        }
    }
    
    fileprivate func CalculateDistance(
        latLoc1: CLLocationDegrees,
        longLoc1: CLLocationDegrees,
        latLoc2: CLLocationDegrees,
        longLoc2: CLLocationDegrees) -> String {
        
        let p1 = CLLocationCoordinate2D(latitude: latLoc1, longitude: longLoc1)
        let p2 = CLLocationCoordinate2D(latitude: latLoc2, longitude: longLoc2)

        let location1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
        let location2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
        let nauticalMilesPerKilometer = 0.539957
        let strDistance = String(format: "%.3f", location2.distance(from: location1) * nauticalMilesPerKilometer / 1000)
        return strDistance
    }
}

#Preview {
    @State var latLoc1: CLLocationDegrees = CLLocationDegrees(floatLiteral: 0.0)
    @State var longaLoc1: CLLocationDegrees = CLLocationDegrees(floatLiteral: 0.0)
    @State var latLoc2: CLLocationDegrees = CLLocationDegrees(floatLiteral: 0.0)
    @State var longLoc2: CLLocationDegrees = CLLocationDegrees(floatLiteral: 0.0)
    
    var viewFormat: ViewFormat = .DDM

    return DistanceView_Original(latLoc1: $latLoc1, longLoc1: $longLoc2, latLoc2: $latLoc2, longLoc2: $longLoc2, viewFormat: viewFormat)
}
*/
