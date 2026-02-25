//
//  MapView_New.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/15/26.
//

import SwiftUI
import CoreLocation
import MapKit
import Foundation

struct LocationsOnMap: View {
    
    @ObservedObject var locObj: LocationObject
    
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    @GestureState private var dragState = DragState.inactive
    
    var body: some View {
        VStack {
            DraggableMapView(locObj: locObj)
            DistanceView
            HintView
        }
        .onAppear {
            locObj.bReturningFromMapView = true
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    fileprivate var DistanceView: some View {
        HStack {
            Text("Distance:")
                .bold()
            Text(locObj.strDistance)
        }
        .frame(height: 30.0)
        .padding(.bottom, 5)
    }
    
    fileprivate var HintView: some View {
        VStack {
            Text("You may move the locations")
            Text("by long-tapping and dragging.")
        }
        .font(.footnote)
        .padding(.bottom, 10)
    }

}

#Preview {
    let locObj = LocationObject()
    LocationsOnMap(locObj: locObj)
}
