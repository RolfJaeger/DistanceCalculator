//
//  LocationsOnMap_New.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/15/26.
//

import SwiftUI

struct LocationsOnMap_New: View {
    
    @StateObject private var locObject = LocationObject()
    
    @State private var showDataEntryView = false
    @State private var locIndex = 0
    
    var body: some View {
        VStack {
            Text("Plotting Helper")
                .font(.largeTitle)
                .bold()
                .padding(.top, 5)
                .padding(.bottom, 5)
            FormatView(locObj: locObject)
            Text("Distance: \(locObject.getDistance()) nm")
                .padding(.bottom,5)
            Text("Location 1")
                .font(Font.system(size: 25, weight: .regular, design: .default))
                .bold()
            HStack {
                Text(locObject.getNorthSouth(0))
                Text("\(locObject.getLatitute(0))")
                    .onTapGesture {
                        showDataEntryView = true
                        locIndex = 0
                        locObject.latLong = .Latitude
                    }
                Text(" | ")
                Text(locObject.getEastWest(0))
                Text("\(locObject.getLongitute(0))")
                    .onTapGesture {
                        showDataEntryView = true
                        locIndex = 0
                        locObject.latLong = .Longitude
                    }
            }
            .font(Font.system(size: 25, weight: .regular, design: .default))

            Text("Location 2")
                .bold()
            HStack {
                Text(locObject.getNorthSouth(1))
                Text("\(locObject.getLatitute(1))")
                    .onTapGesture {
                        showDataEntryView = true
                        locIndex = 1
                        locObject.latLong = .Latitude
                    }
                Text(" | ")
                Text(locObject.getEastWest(1))
                Text("\(locObject.getLongitute(1))")
                    .onTapGesture {
                        showDataEntryView = true
                        locIndex = 1
                        locObject.latLong = .Longitude
                    }
            }
            .font(Font.system(size: 25, weight: .regular, design: .default))
            if showDataEntryView {
                VStack {
                    switch locObject.viewFormat {
                    case .DMS:
                        DecimalDegreesEntryView_New(locObj: locObject, locIndex: locIndex)
                    case .DDM:
                        DMSEntryView_New(locObj: locObject, locIndex: locIndex)
                    case .Raymarine:
                        RaymarineFormatEntryView_New(locObj: locObject, locIndex: locIndex)
                    }
                }
                .frame(height: 75)
            }
            MapView_New(locObj: locObject)
        }
        .font(Font.system(size: 25, weight: .regular, design: .default))
    }
    
}

#Preview {
    let locObj = LocationObject()
    LocationsOnMap_New()
}
