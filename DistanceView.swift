//
//  DistanceView_New.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/19/26.
//

import SwiftUI
import CoreLocation

struct DistanceView: View {
    
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
                LocationSummary(locObj: locObject, locIndex: 0, locIndexToProcess: $locIndex, showDataEntryView: $showDataEntryView)
                LocationSummary(locObj: locObject, locIndex: 1, locIndexToProcess: $locIndex, showDataEntryView: $showDataEntryView)
                if showDataEntryView {
                    DataEntryView
                }
                if !showDataEntryView {
                    HintView
                    Spacer()
                    if locObject.strDistance != "Too Large" {
                        LinkToMap
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
    
    private var DataEntryView: some View {
        VStack {
            VStack {
                switch locObject.viewFormat {
                case .DMS:
                    DMSEntryView(locObj: locObject, locIndex: locIndex, showView: $showDataEntryView)
                case .DDM:
                    DecimalDegreesEntryView(locObj: locObject, locIndex: locIndex, showView: $showDataEntryView)
                case .Raymarine:
                    RaymarineFormatEntryView(locObj: locObject, locIndex: locIndex, showView: $showDataEntryView)
                }
            }
        }
    }
    
    private var LinkToMap: some View {
        VStack {
            NavigationLink(
                destination:
                    LocationsOnMap(locObj: locObject),
                label: {
                    Text("Show Locations on Map")
                        .font(isPad ? .system(size: 25.0) : .title3)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                })
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
    DistanceView()
}
