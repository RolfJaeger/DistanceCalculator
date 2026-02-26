//
//  FormatView.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/15/26.
//

import SwiftUI

struct FormatView: View {
    
    @ObservedObject var locObj: LocationObject

    var txtSwitchFormat: String {
        switch locObj.viewFormat {
        case .DMS:
            return "Switch to Raymarine Format"
        case .DDM:
            return "Switch to Deg Min Sec"
        case .Raymarine:
            return "Switch to Decimal Degress"
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Location Format")
                    .font(isPad ? .system(size: 40.0) : .title)
                    .bold()
                VStack {
                    switch locObj.viewFormat {
                    case .DMS:
                        Text("Degrees | Minutes | Seconds")
                    case .DDM:
                        Text("Decimal Degrees")
                    case .Raymarine:
                        Text("Degrees | Decimal Minutes")
                    }
                }
                .font(isPad ? .system(size: 30.0) : .title2)
            }
            Button(action: {
                switch locObj.viewFormat {
                case .DMS:
                    locObj.viewFormat = .Raymarine
                case .DDM:
                    locObj.viewFormat = .DMS
                case .Raymarine:
                    locObj.viewFormat = .DDM
                }
            }, label: {
                Text(txtSwitchFormat)
                    .font(isPad ? .system(size: 25.0) : .body)
            })
            .buttonStyle(.bordered)
        }
    }
    
}

#Preview {
    let locObj = LocationObject()
    FormatView(locObj: locObj)
}
