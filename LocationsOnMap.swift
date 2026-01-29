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
    
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    @GestureState private var dragState = DragState.inactive
    
    @State private var viewState = CGSize.zero
    @State private var location1: Location
    @State private var location2: Location
    @State private var strDistance: String = "0.0"
    @State private var locations = [Location]()
    
    @State private var region_Rev0 = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    @State private var region: MKCoordinateRegion?

    init(Location1: Binding<Location>,
         Location2: Binding<Location>,
         latSpan: Double,
         longSpan: Double
    ) {
        
        // Assign the incoming bindings directly to the @Binding-backed storage
        _Location1 = Location1
        _Location2 = Location2

        // Initialize local state copies from the wrapped values
        let loc1 = Location1.wrappedValue
        let loc2 = Location2.wrappedValue

        _location1 = State(initialValue: loc1)
        _location2 = State(initialValue: loc2)

        _strDistance = State(initialValue: CalculateDistance(Loc1: loc1, Loc2: loc2))

        _region = State(initialValue:
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: (loc1.coordinate.latitude + loc2.coordinate.latitude) / 2.0,
                                                longitude: (loc1.coordinate.longitude + loc2.coordinate.longitude) / 2.0),
                span: MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: longSpan)
            ))

        _locations = State(initialValue: [loc1, loc2])
        
    }
    
    var body: some View {
        VStack {
            DraggableMapView(locations: $locations, strDistance: $strDistance, region: region)
                .onAppear(perform: {
                    region = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: calcLatCenter(), longitude: calcLongCenter()),
                            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                        )

                })
            DistanceView
            HintView
        }
        .edgesIgnoringSafeArea(.bottom)
        .onDisappear {
            Location1.coordinate = locations[0].coordinate
            Location2.coordinate = locations[1].coordinate
        }
    }
    
    fileprivate var HintView: some View {
        VStack {
            Text("You may move the locations")
            Text("by long-tapping and dragging.")
        }
        .font(.footnote)
        .padding(.bottom, 10)
    }
    
    fileprivate var DistanceView: some View {
        HStack {
            Text("Distance:")
                .bold()
            Text(strDistance)
            Text("nm")
        }
        .frame(height: 30.0)
        .padding(.bottom, 5)
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
        let metersPerPoint = region!.span.latitudeDelta ?? 0.01
        let latOffset = -translation.height * metersPerPoint / 300
        let lonOffset = translation.width * metersPerPoint / 300
        if location.name == "Location 1" {
            location1.coordinate.latitude += latOffset
            location1.coordinate.longitude += lonOffset
        } else {
            location2.coordinate.latitude += latOffset
            location2.coordinate.longitude += lonOffset
        }
    }

    fileprivate func updateCoordinate_Rev1(location: Location, from translation: CGSize) -> Location {
        guard let region = region else { return location }

        let latDelta = region.span.latitudeDelta
        let lonDelta = region.span.longitudeDelta

        let latOffset = -translation.height * latDelta / 300
        let lonOffset = translation.width * lonDelta / 300

        var newLat = location.coordinate.latitude + latOffset
        var newLon = location.coordinate.longitude + lonOffset

        let minLat = region.center.latitude - latDelta / 2
        let maxLat = region.center.latitude + latDelta / 2
        let minLon = region.center.longitude - lonDelta / 2
        let maxLon = region.center.longitude + lonDelta / 2

        newLat = clamp(newLat, min: minLat, max: maxLat)
        newLon = clamp(newLon, min: minLon, max: maxLon)

        let newLocation = Location(
            coordinate: CLLocationCoordinate2D(latitude: newLat, longitude: newLon),
            name: location.name)
        return newLocation
    }
    
    fileprivate func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        Swift.min(Swift.max(value, min), max)
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

