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

    //var viewFormat: ViewFormat = .Raymarine
    @State var viewFormat: ViewFormat = .Raymarine
    @State var location: Location = Location(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0), name: "Test Loc")
    
    var body: some Scene {
        WindowGroup {
            DistanceView(viewFormat: viewFormat)
            //TestOfDraggableMapView()
            //LocationDBView(viewFormat: $viewFormat, currentLocation: $location)
        }
    }
}
