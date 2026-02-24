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

struct MapView_New: View {
    
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
    
    @State private var viewState = CGSize.zero
    @State private var strDistance: String = "0.0"
    @State private var locations = [Location]()
    
    var body: some View {
        VStack {
            DraggableMapView_New(locObj: locObj, strDistance: $strDistance)
            DistanceView
            HintView
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            locations = [locObj.Location1,  locObj.Location2]
            strDistance = CalculateDistance(Loc1: locObj.locations[0], Loc2: locObj.locations[1])
        }
        .onDisappear {
        }
        
    }
    
    fileprivate var DistanceView: some View {
        HStack {
            Text("Distance:")
                .bold()
            Text(strDistance)
            Text("nm")
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
    MapView_New(locObj: locObj)
}
