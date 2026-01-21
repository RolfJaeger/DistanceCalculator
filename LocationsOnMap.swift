//
//  LocationsOnMap.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 1/15/26.
//

import SwiftUI
import CoreLocation
import MapKit
import Foundation

struct LocationsOnMap: View {
    
    @Binding var Location1: Location
    @Binding var Location2: Location
    
    //@State private var location1 = Location(coordinate: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -120.05), name: "Location 1")
    @State private var location1: Location
    @State private var location2: Location
    
    @State private var region = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    init(Location1: Binding<Location>,
         Location2: Binding<Location>,
         latSpan: Double,
         longSpan: Double
    ) {
        
        _Location1 = Location1
        _Location2 = Location2

        _location1 = State(
            initialValue: Location1.wrappedValue)

        _location2 = State(
            initialValue: Location2.wrappedValue)

        _region = State(initialValue:  MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: calcLatCenter(), longitude: calcLongCenter()),
                span: MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: longSpan)
            )
            ))
    }
    var body: some View {
        Map(position: $region) {
            Annotation(coordinate: location1.coordinate,
                       content: {
                Circle()
                    .fill(.blue)
                    .frame(width: 24, height: 24)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateCoordinate(location: location1,  from: value.translation)
                                Location1 = location1
                            }
                    )

            }, label: {
                Text(location1.name)
            })
            Annotation(coordinate: location2.coordinate,
                       content: {
                Circle()
                    .fill(.red)
                    .frame(width: 24, height: 24)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateCoordinate(location: location2,  from: value.translation)
                                Location2 = location2
                            }
                        
                    )
            }, label: {
                Text(location2.name)
            })
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

    fileprivate func updateCoordinate(location: Location, from translation: CGSize) {
        if abs(translation.height) > 100 || abs(translation.width) > 100 {
            return
        }
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

/*
struct CustomDraggableAnnotationView: View {
    
    @Binding var location: Location
    
    var mapProxy: MapProxy? // Pass the map proxy here
    
    var body: some View {
        if location.name == "Location 1" {
            Image(systemName: "pin.fill")
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(.blue).shadow(radius: 4))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if let newCoordinate = mapProxy?.convert(value.location, from: .local) {
                                location.coordinate = newCoordinate
                            }
                        }
                )

        } else {
            Image(systemName: "pin.fill")
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(.red).shadow(radius: 4))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if let newCoordinate = mapProxy?.convert(value.location, from: .local) {
                                location.coordinate = newCoordinate
                            }
                        }
                )
        }
    }
    
}
*/

#Preview {
    @Previewable @State var Loc1 = Location(coordinate: CLLocationCoordinate2D(latitude: 37.5890, longitude: -122.5890), name: "Location 1")
    @Previewable @State var Loc2 = Location(coordinate: CLLocationCoordinate2D(latitude: 37.5890, longitude: -122.5890), name: "Location 1")

    LocationsOnMap(
        Location1: $Loc1,
        Location2: $Loc2,
        latSpan: 0.1,
        longSpan: 0.1)
}
