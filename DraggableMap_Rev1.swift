//
//  raggableMap_Rev1.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 1/20/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct DraggableMap_Rev1: View {
    @State private var location = Location(
        coordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090), name: "Location 1"
    )

    @State private var region = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    var body: some View {
        Map(position: $region) {
            Annotation("Drag me", coordinate: location.coordinate) {
                Circle()
                    .fill(.red)
                    .frame(width: 24, height: 24)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateCoordinate(from: value.translation)
                            }
                    )
            }
        }
    }

    private func updateCoordinate(from translation: CGSize) {
        let metersPerPoint = region.region?.span.latitudeDelta ?? 0.01
        let latOffset = -translation.height * metersPerPoint / 300
        let lonOffset = translation.width * metersPerPoint / 300

        location.coordinate.latitude += latOffset
        location.coordinate.longitude += lonOffset
    }
}


#Preview {
    DraggableMap_Rev1()
}
