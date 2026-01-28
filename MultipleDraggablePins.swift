//
//  MultipleDraggablePins.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 1/26/26.
//

import SwiftUI
import CoreLocation
import MapKit

struct MultipleDraggablePins: View {
    
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    
    @State private var locations: [Location] = [
        Location(coordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090), name: "Location 1"),
        Location(coordinate: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0090), name: "Location 2"),
        Location(coordinate: CLLocationCoordinate2D(latitude: 37.5, longitude: -122.0090), name: "Location 3")
    ]
    
    @State private var dragStartCoordinate: CLLocationCoordinate2D?
    @State private var dragStartPoint: CGPoint?
    @State private var draggingID: UUID?

    @State private var mapInteraction: MapInteractionModes = .all
    
    var body: some View {
        MapReader { proxy in
            Map(position: $cameraPosition,
                interactionModes: mapInteraction) {
                
                ForEach($locations) { $location in
                    Annotation("", coordinate: location.coordinate) {
                        Circle()
                            .fill(draggingID == location.id ? .red : .blue)
                            .frame(width: 26, height: 26)
                            .contentShape(Circle())
                        /*
                         .gesture(
                         LongPressGesture(minimumDuration: 0.2)
                         .sequenced(before: DragGesture())
                         .onChanged { value in
                         switch value {
                         case .first(true):
                         draggingID = location.id
                         mapInteraction = []   // disable map gestures
                         
                         case .second(true, let drag):
                         if let drag {
                         updateLocation(
                         location: $location,
                         dragLocation: drag.location,
                         proxy: proxy
                         )
                         }
                         
                         default:
                         break
                         }
                         }
                         .onEnded { _ in
                         draggingID = nil
                         mapInteraction = .all
                         }
                         )
                         */
                            .highPriorityGesture(
                                LongPressGesture(minimumDuration: 0.2)
                                    .sequenced(before: DragGesture())
                                    .onChanged { value in
                                        switch value {
                                        case .first(true):
                                            draggingID = location.id
                                            
                                        case .second(true, let drag):
                                            guard let drag else { return }
                                            updateLocation(
                                                location: $location,
                                                drag: drag,
                                                proxy: proxy
                                            )
                                            
                                        default:
                                            break
                                        }
                                    }
                                    .onEnded { _ in
                                        draggingID = nil
                                        dragStartCoordinate = nil
                                        dragStartPoint = nil
                                    }
                            )
                    }
                }
            }
                .onChange(of: cameraPosition) {
                    resetDragState()
                }
        }

    }
    
    private func resetDragState() {
        draggingID = nil
        dragStartCoordinate = nil
        dragStartPoint = nil
    }

    private func updateLocation(
        location: Binding<Location>,
        drag: DragGesture.Value,
        proxy: MapProxy
    ) {
        guard let region = cameraPosition.region else { return }

        // Capture drag origin ONCE
        if dragStartCoordinate == nil {
            dragStartCoordinate = location.wrappedValue.coordinate
            dragStartPoint = drag.startLocation
        }

        guard
            let startCoord = dragStartCoordinate,
            let startPoint = dragStartPoint,
            let currentCoord = proxy.convert(drag.location, from: .global),
            let startMapCoord = proxy.convert(startPoint, from: .global)
        else { return }

        // Delta in geo space
        let latDelta = currentCoord.latitude - startMapCoord.latitude
        let lonDelta = currentCoord.longitude - startMapCoord.longitude

        var newLat = startCoord.latitude + latDelta
        var newLon = startCoord.longitude + lonDelta

        // Clamp to visible region
        let minLat = region.center.latitude - region.span.latitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        let minLon = region.center.longitude - region.span.longitudeDelta / 2
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2

        newLat = min(max(newLat, minLat), maxLat)
        newLon = min(max(newLon, minLon), maxLon)

        location.wrappedValue.coordinate = CLLocationCoordinate2D(
            latitude: newLat,
            longitude: newLon
        )
    }

}
#Preview {
    MultipleDraggablePins()
}
