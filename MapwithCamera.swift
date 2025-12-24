//
//  mapwithCamera.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 3/6/25.
//

import SwiftUI
import MapKit

struct MapwithCamera: View {
    
    @StateObject private var locM = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        VStack {
            Map(position: $cameraPosition) {
                Marker("MBHY", coordinate: .mbyh)
                Annotation("RYC", coordinate: .ryc) {
                    ZStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 35, height: 35, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        Text("2")
                            .bold()
                            .font(.title)
                            
                    }
                }
                .annotationTitles(.hidden)
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
            }
            .onReceive(locM.$direction) { direction in
                                    cameraPosition =  .camera(MapCamera(
                                        centerCoordinate: self.locM.location.coordinate,
                                        distance: locM.cameraDistance,
                                        heading: direction
                                    ))
                                }
            .onMapCameraChange { mapCameraUpdateContext in
                locM.cameraDistance = mapCameraUpdateContext.camera.distance
            }
            .safeAreaInset(edge: .bottom, content: {Text("Just a test   ")})
        }
    }
}

#Preview {
    MapwithCamera()
}
