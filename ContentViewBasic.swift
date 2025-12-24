//
//  ContentView.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 3/5/25.
//

import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let mbyh: Self = .init(
        latitude: 37.91339,
        longitude: -122.35
    )
    static let ryc: Self = .init(
        latitude: 37.91339,
        longitude: -122.38
    )
}

struct ContentViewBasic: View {
    
    @StateObject private var locM = LocationManager()
        
    var body: some View {
        VStack {
            Map {
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
            .safeAreaInset(edge: .bottom, content: {Text("Just a test   ")})
        }
    }
}

#Preview {
    ContentViewBasic()
}
