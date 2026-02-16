//
//  LocationsOnMap_New.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/15/26.
//

import SwiftUI

struct LocationsOnMap_New: View {
    
    @StateObject private var locObject = LocationObject()
    
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
                Text(" | ")
                Text(locObject.getEastWest(0))
                Text("\(locObject.getLongitute(0))")
            }
            .font(Font.system(size: 25, weight: .regular, design: .default))

            Text("Location 2")
                .bold()
            HStack {
                Text(locObject.getNorthSouth(1))
                Text("\(locObject.getLatitute(1))")
                Text(" | ")
                Text(locObject.getEastWest(1))
                Text("\(locObject.getLongitute(1))")
            }
            .font(Font.system(size: 25, weight: .regular, design: .default))
            MapView_New(locObj: locObject)
        }
        .font(Font.system(size: 25, weight: .regular, design: .default))
    }
    
}

#Preview {
    LocationsOnMap_New()
}
