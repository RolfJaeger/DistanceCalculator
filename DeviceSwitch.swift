//
//  DeviceSwitch.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/15/26.
//

import SwiftUI

struct DeviceSwitch: View {

    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        if sizeClass == .regular {
            DistanceView_iPad()
        } else {
            DistanceView()
        }
    }
}

#Preview {
    DeviceSwitch()
}
