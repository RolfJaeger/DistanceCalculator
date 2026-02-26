//
//  LocationSummary.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/24/26.
//

import SwiftUI

struct LocationSummary: View {
    
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var locObj: LocationObject

    @Binding var showDataEntryView: Bool
    @Binding var locIndexToProcess: Int
    
    var locIndex: Int
    
    init(locObj: LocationObject, locIndex: Int, locIndexToProcess: Binding<Int>, showDataEntryView: Binding<Bool>) {
        _showDataEntryView = showDataEntryView
        _locIndexToProcess = locIndexToProcess
        self.locObj = locObj
        self.locIndex = locIndex
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if let userLocation = locationManager.lastKnownLocation {
                        locObj.updateLocations(indexToUpdate: locIndex, newLocation: userLocation)
                    }
                }, label: {
                    Text("Location \(locIndex + 1)")
                })
                .buttonStyle(.bordered)
                .disabled(showDataEntryView)
                if !showDataEntryView {
                    NavigationLink(
                        destination:
                            LocationDBView(locObj: locObj, locIndex: locIndex),
                        label: {
                            Image(systemName: "bookmark")
                        })
                }
            }
            .font(isPad ? .system(size: 30.0) : .title3)
            .bold()
            .padding(.bottom,5)
            HStack {
                Text(locObj.getNorthSouth(locIndex))
                Text("\(locObj.getLatitute(locIndex))")
                    .onTapGesture {
                        if !showDataEntryView {
                            showDataEntryView = true
                            locObj.latLong = .Latitude
                            locIndexToProcess = locIndex
                            locObj.maxDegrees = 89
                            locObj.setHemisphere(locIndex: locIndex)
                        }
                    }
                Text(" | ")
                Text(locObj.getEastWest(locIndex))
                Text("\(locObj.getLongitute(locIndex))")
                    .onTapGesture {
                        if !showDataEntryView {
                            showDataEntryView = true
                            locObj.latLong = .Longitude
                            locIndexToProcess = locIndex
                            locObj.maxDegrees = 179
                            locObj.setHemisphere(locIndex: locIndex)
                        }
                    }
            }
            .font(isPad ? .system(size: 35.0) : .title3)
            .padding(.bottom, 5)
        }
        .onAppear {
            if !locObj.bReturningFromMapView {
                locObj.bReturningFromMapView = false
                if let userLocation = self.locationManager.lastKnownLocation {
                    locObj.initializeLocationsWithCurrentLocation(currentLocation: userLocation)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var show = false
    @Previewable @State var locIndexToProcess = 0
    let locObj = LocationObject()
    LocationSummary(locObj: locObj, locIndex: 0, locIndexToProcess: $locIndexToProcess,  showDataEntryView: $show)
}
