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
    
    //@State private var location2 = Location(coordinate: CLLocationCoordinate2D(latitude: 35.011_386, longitude: -120.0), name: "Location 2")
    @State private var location2: Location
    
    init(Location1: Binding<Location>,
         Location2: Binding<Location>) {
        
        _Location1 = Location1
        _Location2 = Location2

        _location1 = State(
            initialValue: Location1.wrappedValue)

        _location2 = State(
            initialValue: Location2.wrappedValue)

    }
    var body: some View {
        MapReader { reader in // 1. Wrap the map in a MapReader
            Map {
                Annotation(coordinate: location1.coordinate,
                           content: {
                    CustomDraggableAnnotationView(location: $Location1,
                        mapProxy: reader)
                }, label: {
                    Text(location1.name)
                })
                Annotation(coordinate: location1.coordinate,
                           content: {
                    CustomDraggableAnnotationView(location: $Location2,
                        mapProxy: reader)
                }, label: {
                    Text(location2.name)
                })
            }
        }
    }
}

struct CustomDraggableAnnotationView_Rev0: View {
    
    @Binding var coordinate: CLLocationCoordinate2D
    @Binding var latLoc: CLLocationDegrees
    @Binding var longLoc: CLLocationDegrees

    var mapProxy: MapProxy? // Pass the map proxy here
    
    var locationName: String

    var body: some View {
        if locationName == "Location 1" {
            Image(systemName: "pin.fill")
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(.blue).shadow(radius: 4))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if let newCoordinate = mapProxy?.convert(value.location, from: .local) {
                                coordinate = newCoordinate
                                latLoc = coordinate.latitude
                                longLoc = coordinate.longitude
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
                                coordinate = newCoordinate
                            }
                        }
                )
        }
    }
}

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


#Preview {
    @Previewable @State var Loc1 = Location(coordinate: CLLocationCoordinate2D(latitude: 37.5890, longitude: -122.5890), name: "Location 1")
    @Previewable @State var Loc2 = Location(coordinate: CLLocationCoordinate2D(latitude: 37.5890, longitude: -122.5890), name: "Location 1")

    LocationsOnMap(
        Location1: $Loc1,
        Location2: $Loc2)
}
