//
//  TestOfDraggableMapView.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 1/27/26.
//

import SwiftUI
import CoreLocation
import MapKit

struct TestOfDraggableMapView: View {

    @State private var locations: [Location] = [
        Location(coordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090), name: "Location 1"),
        Location(coordinate: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0090), name: "Location 2"),
        Location(coordinate: CLLocationCoordinate2D(latitude: 37.5, longitude: -122.0090), name: "Location 3")
    ]
    
    @State private var strDistance = "0.0"

    var body: some View {
        DraggableMapView(locations: $locations, strDistance: $strDistance, region: nil)
            .ignoresSafeArea()
    }
}

#Preview {
    TestOfDraggableMapView()
}
