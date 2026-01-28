//
//  DraggablePin.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 1/23/26.
//

import SwiftUI
import MapKit
import Foundation

class DraggablePin: ObservableObject, Identifiable {
    let id = UUID()
    @Published var coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

struct DraggablePinView: View {
    
    @StateObject private var pin = DraggablePin(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))

    var body: some View {
        MapReader { proxy in // Use MapReader to access map coordinates
            Map(initialPosition: .region(MKCoordinateRegion(
                center: pin.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))) {
                Annotation("Draggable Pin", coordinate: pin.coordinate) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title)
                        .foregroundColor(.red)
                        .contentShape(Rectangle()) // Make the whole image area interactive
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Translate screen location to map coordinate
                                    if let newCoordinate = proxy.convert(value.location, from: .local) {
                                        pin.coordinate = newCoordinate
                                    }
                                }
                                .onEnded { value in
                                    // Optional: Handle the end of the drag (e.g., save location)
                                    if let newCoordinate = proxy.convert(value.location, from: .local) {
                                        print("Pin dropped at: \(newCoordinate.latitude), \(newCoordinate.longitude)")
                                    }
                                }
                        )
                }
            }
        }
    }
}
