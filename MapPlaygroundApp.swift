//
//  MapPlaygroundApp.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 3/5/25.
//

import SwiftUI
import CoreLocation

@main
struct MapPlaygroundApp: App {

    @State var latLoc1: CLLocationDegrees = CLLocationDegrees(floatLiteral: 37.5)
    @State var longLoc1: CLLocationDegrees = CLLocationDegrees(floatLiteral: 122.0)
    @State var latLoc2: CLLocationDegrees = CLLocationDegrees(floatLiteral: 37.0)
    @State var longLoc2: CLLocationDegrees = CLLocationDegrees(floatLiteral: 122.0)

    var viewFormat: ViewFormat = .Raymarine

    var body: some Scene {
        WindowGroup {
            DistanceView(latLoc1: $latLoc1, longLoc1: $longLoc1, latLoc2: $latLoc2, longLoc2: $longLoc2, viewFormat: viewFormat)
        }
    }
}
