//
//  DistanceView_New.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/19/26.
//

import SwiftUI
import CoreLocation

struct DistanceView_New: View {
    
    @StateObject private var locObject = LocationObject()
    @Binding var strDistance: String
    
    @State private var showDataEntryView = false
    @State private var locIndex = 0
    
    var body: some View {
        NavigationStack {
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
                            locObject.setHemisphere(locIndex: 0)
                        }
                    Text(" | ")
                    Text(locObject.getEastWest(0))
                    Text("\(locObject.getLongitute(0))")
                        .onTapGesture {
                            showDataEntryView = true
                            locIndex = 0
                            locObject.latLong = .Longitude
                            locObject.setHemisphere(locIndex: 0)
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
                            locObject.setHemisphere(locIndex: 1)
                        }
                    Text(" | ")
                    Text(locObject.getEastWest(1))
                    Text("\(locObject.getLongitute(1))")
                        .onTapGesture {
                            showDataEntryView = true
                            locIndex = 1
                            locObject.latLong = .Longitude
                            locObject.setHemisphere(locIndex: 1)
                        }
                }
                .font(Font.system(size: 25, weight: .regular, design: .default))
                if showDataEntryView {
                    VStack {
                        switch locObject.viewFormat {
                        case .DMS:
                            DMSEntryView_New(locObj: locObject, locIndex: locIndex)
                        case .DDM:
                            DecimalDegreesEntryView_New(locObj: locObject, locIndex: locIndex, showView: $showDataEntryView)
                        case .Raymarine:
                            RaymarineFormatEntryView_New(locObj: locObject, locIndex: locIndex)
                        }
                    }
                    //.frame(height: 75)
                }
                if !showDataEntryView {
                    Spacer()
                    NavigationLink(
                        destination:
                            MapView_New(locObj: locObject),
                        label: {
                            Text("Show Locations on Map")
                                .font(.title3)
                                .padding(.top, 20)
                        })
                }
            }
            .font(Font.system(size: 25, weight: .regular, design: .default))
        }
    }
    
}

#Preview {
    @Previewable @State var strDistance = "0.0"
    DistanceView_New(strDistance: $strDistance)
}
