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

    var body: some Scene {
        WindowGroup {
            //DeviceSwitch()
            //TestOfDraggableMapView()
            //LocationDBView(location: $location)
            
            //LocationsOnMap_New()
            DistanceView_New()
        }
    }
}
