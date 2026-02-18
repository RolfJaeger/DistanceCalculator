//
//  LocationDetailView.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/16/26.
//

import SwiftUI

struct LocationDetailView: View {
    
    @ObservedObject var locObj: LocationObject

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let locObj = LocationObject()
    LocationDetailView(locObj: locObj)
}
