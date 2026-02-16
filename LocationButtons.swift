//
//  LocationSummary.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/15/26.
//

import SwiftUI
import CoreLocation

struct LocationButtons: View {
    
    @ObservedObject var locationManager = LocationManager()

    @Binding var location: Location
    var viewFormat: ViewFormat
    
    init(location: Binding<Location>, viewFormat: ViewFormat) {
        _location = location
        self.viewFormat = viewFormat
    }
    
    var body: some View {
        HStack {
            Button(action: {
                if let userLocation = locationManager.lastKnownLocation {
                    location.coordinate.latitude = userLocation.latitude.rounded(toPlaces: 3)
                    location.coordinate.longitude = userLocation.longitude.rounded(toPlaces: 3)
                }
            }, label: {
                Text(location.name)
                    .font(Font.system(size: 40, weight: .bold, design: .default))
                    .bold()
                    .padding(.top, 10)
                    .padding(.bottom, 5)
            })
            .buttonStyle(.bordered)
            .padding(.top, 10)
            .padding(.bottom, 5)
            NavigationLink(
                destination:
                    LocationDBView( location: $location),
                label: {
                    Image(systemName: "bookmark")
                        .font(Font.system(size: 30, weight: .regular, design: .default))
                })
        }

    }
}

#Preview {
    @Previewable @State var location = Location(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122), name: "Test")
    var viewFormat: ViewFormat = .DDM
    LocationButtons(location: $location, viewFormat: viewFormat)
}
