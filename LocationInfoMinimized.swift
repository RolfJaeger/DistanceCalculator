//
//  LocationInfoMinimized.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/15/26.
//

import SwiftUI
import CoreLocation

struct LocationInfoMinimized: View {
    
    @Binding var location: Location
    
    var viewFormat: ViewFormat = .DDM
    var latLong: LatLong = .Latitude
    
    init(location: Binding<Location>, viewFormat: ViewFormat, latLong: LatLong) {
        _location = location
        self.viewFormat = viewFormat
        self.latLong = latLong
    }
    
    var body: some View {
        HStack {
            if latLong == .Latitude {
                Text(DegreesToStringInSelectedFormat(degrees: location.coordinate.latitude, viewFormat: viewFormat))
            } else {
                Text(DegreesToStringInSelectedFormat(degrees: location.coordinate.longitude, viewFormat: viewFormat))
            }
        }
        .font(Font.system(size: dataFont, weight: .regular, design: .default))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
}

#Preview {
    @Previewable @State var location = Location(coordinate: CLLocationCoordinate2D(latitude: 37, longitude: -122), name: "Test Location")
    var viewFormat: ViewFormat = .DDM
    var latLong: LatLong = .Longitude
    LocationInfoMinimized(location: $location, viewFormat: viewFormat, latLong: latLong)
}
