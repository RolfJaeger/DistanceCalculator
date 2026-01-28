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

    var viewFormat: ViewFormat = .Raymarine

    var body: some Scene {
        WindowGroup {
            DistanceView(viewFormat: viewFormat)
            //DraggablePinView()
            //MultipleDraggablePins()
            //TestOfDraggableMapView()
        }
    }
}
