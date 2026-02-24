//
//  DistanceView_New.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/19/26.
//

import SwiftUI
import CoreLocation

struct DistanceView_New: View {
    
    @ObservedObject var locationManager = LocationManager()

    @StateObject private var locObject = LocationObject()

    @State private var showDataEntryView = false
    @State private var locIndex = 0

    var body: some View {
        NavigationStack {
            VStack {
                TitleView
                FormatView(locObj: locObject)
                DistanceView
                HStack {
                    Button(action: {
                        if let userLocation = locationManager.lastKnownLocation {
                            locObject.setLocationToCurrentLocation(currentLocation: userLocation, locIndex: 0)
                        }
                    }, label: {
                        Text("Location 1")
                    })
                    .buttonStyle(.bordered)
                    .disabled(showDataEntryView)
                    if !showDataEntryView {
                        NavigationLink(
                            destination:
                                LocationDBView_New(locObj: locObject, locIndex: 0),
                            label: {
                                Image(systemName: "bookmark")
                            })
                    }
                }
                .font(isPad ? .system(size: 30.0) : .title3)
                .bold()
                .padding(.bottom,5)
                HStack {
                    Text(locObject.getNorthSouth(0))
                    Text("\(locObject.getLatitute(0))")
                        .onTapGesture {
                            if !showDataEntryView {
                                showDataEntryView = true
                                locIndex = 0
                                locObject.latLong = .Latitude
                                locObject.maxDegrees = 89
                                locObject.setHemisphere(locIndex: 0)
                            }
                        }
                    Text(" | ")
                    Text(locObject.getEastWest(0))
                    Text("\(locObject.getLongitute(0))")
                        .onTapGesture {
                            if !showDataEntryView {
                                showDataEntryView = true
                                locIndex = 0
                                locObject.latLong = .Longitude
                                locObject.maxDegrees = 179
                                locObject.setHemisphere(locIndex: 0)
                            }
                        }
                }
                .font(isPad ? .system(size: 35.0) : .title3)
                .padding(.bottom, 5)
                HStack {
                    Button(action: {
                        if let userLocation = locationManager.lastKnownLocation {
                            locObject.locations[1].coordinate.latitude = userLocation.latitude.rounded(toPlaces: 3)
                            locObject.locations[1].coordinate.longitude = userLocation.longitude.rounded(toPlaces: 3)
                        }
                    }, label: {
                        Text("Location 2")
                            .bold()
                    })
                    .disabled(showDataEntryView)
                    .buttonStyle(.bordered)
                    if !showDataEntryView {
                        NavigationLink(
                            destination:
                                LocationDBView_New(locObj: locObject, locIndex: 1),
                            label: {
                                Image(systemName: "bookmark")
                            })
                    }
                }
                .font(isPad ? .system(size: 30.0) : .title3)
                .padding(.bottom,5)
                HStack {
                    Text(locObject.getNorthSouth(1))
                    Text("\(locObject.getLatitute(1))")
                        .onTapGesture {
                            if !showDataEntryView {
                                showDataEntryView = true
                                locIndex = 1
                                locObject.latLong = .Latitude
                                locObject.maxDegrees = 89
                                locObject.setHemisphere(locIndex: 1)
                            }
                        }
                    Text(" | ")
                    Text(locObject.getEastWest(1))
                    Text("\(locObject.getLongitute(1))")
                        .onTapGesture {
                            if !showDataEntryView {
                                showDataEntryView = true
                                locIndex = 1
                                locObject.latLong = .Longitude
                                locObject.maxDegrees = 179
                                locObject.setHemisphere(locIndex: 1)
                            }
                        }
                }
                .font(isPad ? .system(size: 35.0) : .title3)
                if showDataEntryView {
                    VStack {
                        switch locObject.viewFormat {
                        case .DMS:
                            DMSEntryView_New(locObj: locObject, locIndex: locIndex, showView: $showDataEntryView)
                        case .DDM:
                            DecimalDegreesEntryView_New(locObj: locObject, locIndex: locIndex, showView: $showDataEntryView)
                        case .Raymarine:
                            RaymarineFormatEntryView_New(locObj: locObject, locIndex: locIndex, showView: $showDataEntryView)
                        }
                    }
                    //.frame(height: 75)
                }
                if !showDataEntryView {
                    HintView
                    Spacer()
                    if locObject.strDistance != "Too Large" {
                        NavigationLink(
                            destination:
                                MapView_New(locObj: locObject),
                            label: {
                                Text("Show Locations on Map")
                                    .font(isPad ? .system(size: 25.0) : .title3)
                                    .padding(.top, 20)
                                    .padding(.bottom, 20)
                            })
                    }
                }
            }
            .onAppear {
                if !locObject.bReturningFromMapView {
                    locObject.bReturningFromMapView = false
                    if let userLocation = self.locationManager.lastKnownLocation {
                        locObject.initializeLocationsWithCurrentLocation(currentLocation: userLocation)
                    }

                }
            }
        }
    }
    
    private var TitleView: some View {
        VStack {
            Text("Plotting Helper")
                .font(isPad ? .system(size: 50.0) : .largeTitle)
                .bold()
                .padding(.top, 5)
                .padding(.bottom, 5)
        }
    }

    private var DistanceView: some View {
        VStack {
            Text("Distance: \(locObject.strDistance)")
                .padding(.bottom,5)
                .font(isPad ? .system(size: 30.0) : .title3)
        }
    }
    fileprivate var HintView: some View {
        VStack {
            Text("Initially your location is shown.")
                .padding(.top, 20)
            Text("Tap coordinates to modify")
            Text("or tap the location buttons to ping.")
        }
        .font(isPad ? .system(size: 20.0) : .footnote)
    }
}

#Preview {
    DistanceView_New()
}
