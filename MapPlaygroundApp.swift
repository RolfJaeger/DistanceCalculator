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

    @State var location: Location = Location(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122), name: "Location 1")
    @State var strDistance = "0.0"
    
    //let locObj = LocationObject()
    var body: some Scene {
        WindowGroup {
            //DeviceSwitch()
            //TestOfDraggableMapView()
            //LocationDBView(location: $location)
            
            //LocationsOnMap_New()
            DistanceView_New(strDistance: $strDistance)
        }
    }
}
