//
//  DraggableMap.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 1/20/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct DraggableMap: View {

    @State private var location1 = Location(
        coordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090), name: "Location 1"
    )

    @State private var location2 = Location(
        coordinate: CLLocationCoordinate2D(latitude: 37.3449, longitude: -122.0090), name: "Location 2"
    )

    @State private var region = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    init() {
        _region = State(initialValue:  MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: calcLatCenter(), longitude: calcLongCenter()),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            )
        )
    }

    var body: some View {
        Map(position: $region) {
            Annotation(location1.name, coordinate: location1.coordinate) {
                Circle()
                    .fill(.blue)
                    .frame(width: 24, height: 24)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateCoordinate(location: location1,  from: value.translation)
                            }
                            /*
                            .onEnded { value  in
                                updateCoordinate(location: location1,  from: value.translation)
                            }
                            */
                    )
            }
            Annotation(location2.name, coordinate: location2.coordinate) {
                Circle()
                    .fill(.red)
                    .frame(width: 24, height: 24)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateCoordinate(location: location2,  from: value.translation)
                            }
                            /*
                            .onEnded { value  in
                                updateCoordinate(location: location2,  from: value.translation)
                            }
                            */
                    )
            }
        }
    }

    fileprivate func calcLatCenter() -> CLLocationDegrees {
        let center = (location1.coordinate.latitude + location2.coordinate.latitude)/2.0
        return center
    }

    fileprivate func calcLongCenter() -> CLLocationDegrees {
        let center = (location1.coordinate.longitude + location2.coordinate.longitude) / 2.0
        return center
    }

    fileprivate func calcLatDelta() -> CLLocationDegrees {
        let delta = abs(location1.coordinate.latitude - location2.coordinate.latitude) * 1.1
        return delta
    }

    fileprivate func calcLongDelta() -> CLLocationDegrees {
        let delta = abs(location1.coordinate.longitude - location2.coordinate.longitude) * 1.1
        return delta
    }

    fileprivate func updateCoordinate_Rev0(location: Location, from translation: CGSize) {
        let offsetLimiter = 0.00005
        let metersPerPoint = region.region?.span.latitudeDelta ?? 0.01
        let latOffset = -translation.height * metersPerPoint / 300
        let lonOffset = translation.width * metersPerPoint / 300
        print("Current Lat: \(location.coordinate.latitude) | Current Long: \(location.coordinate.longitude)")
        print("Lat Offset: \(latOffset) | Long Offset: \(lonOffset)")
        if location.name == "Location 1" {
            if abs(latOffset) < abs(location1.coordinate.latitude) * offsetLimiter &&
                abs(lonOffset) < abs(location1.coordinate.longitude) * offsetLimiter {
                location1.coordinate.latitude += latOffset
                location1.coordinate.longitude += lonOffset
            }
        } else {
            if abs(latOffset) < abs(location2.coordinate.latitude) * offsetLimiter &&
                abs(lonOffset) < abs(location2.coordinate.longitude) * offsetLimiter {
                location2.coordinate.latitude += latOffset
                location2.coordinate.longitude += lonOffset
            }
        }
    }

    fileprivate func updateCoordinate(location: Location, from translation: CGSize) {
        let metersPerPoint = region.region?.span.latitudeDelta ?? 0.01
        let latOffset = -translation.height * metersPerPoint / 300
        let lonOffset = translation.width * metersPerPoint / 300
        print("Current Lat: \(location.coordinate.latitude) | Current Long: \(location.coordinate.longitude)")
        print("Lat Offset: \(latOffset) | Long Offset: \(lonOffset)")
        if location.name == "Location 1" {
            location1.coordinate.latitude += latOffset
            location1.coordinate.longitude += lonOffset
        } else {
            location2.coordinate.latitude += latOffset
            location2.coordinate.longitude += lonOffset
        }
    }

}

#Preview {
    DraggableMap()
}
