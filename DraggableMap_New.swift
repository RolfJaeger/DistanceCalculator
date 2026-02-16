//
//  DraggableMap_New.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/15/26.
//

import SwiftUI
import Foundation
import CoreLocation
import MapKit

class CustomAnnotationView_New : MKPinAnnotationView
{
    let helloLabel:UILabel = UILabel.init(frame:CGRectMake(-40, 30, 100, 40)) //your desired frame

    func showLabel(title : String)
    {
        helloLabel.text = title
        helloLabel.textAlignment = .center
        //set further properties
        self.addSubview(helloLabel)
    }

    func hideLabel() {
        helloLabel.removeFromSuperview()
    }
}

final class Coordinator_New: NSObject, MKMapViewDelegate {

    var parent: DraggableMapView_New
    private var annotations: [UUID: MKPointAnnotation] = [:]

    init(_ parent: DraggableMapView_New) {
        self.parent = parent
    }

    func annotation(for location: Location) -> MKPointAnnotation {
        if let existing = annotations[location.id] {
            return existing
        }

        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotations[location.id] = annotation
        annotation.title = location.name
        return annotation
    }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView {

        let view = CustomAnnotationView_New(annotation: annotation, reuseIdentifier: nil)
        view.showLabel(title: annotation.title!!)
        view.pinTintColor = annotation.title == "Location 1" ? .blue : .red
        //view.focusEffect =
        view.isDraggable = true
        view.canShowCallout = false
        return view
    }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState) {

        guard newState == .ending,
              let coord = view.annotation?.coordinate else { return }

        if let index = parent.locObj.locations.firstIndex(where: {
            annotations[$0.id] === view.annotation
        }) {
            parent.locObj.locations[index].coordinate = coord
            print("\(parent.locObj.locations[index].coordinate.latitude), \(parent.locObj.locations[index].coordinate.longitude)")
            //parent.strDistance = CalculateDistance(Loc1: parent.locations[0], Loc2: parent.locations[1])

            
        }

        view.dragState = .none
    }
}

struct DraggableMapView_New: UIViewRepresentable {

    @ObservedObject var locObj: LocationObject
    
    fileprivate func calcLatCenter() -> CLLocationDegrees {
        let center = (locObj.Location1.coordinate.latitude + locObj.Location2.coordinate.latitude)/2.0
        return center
    }

    fileprivate func calcLongCenter() -> CLLocationDegrees {
        let center = (locObj.Location1.coordinate.longitude + locObj.Location2.coordinate.longitude) / 2.0
        return center
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = locObj.region!
        mapView.addAnnotations(locObj.locations.map { context.coordinator.annotation(for: $0) })
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        //TODO: Update the locations here using mapView.annotations[0].coordinate and ... [1].coordinate
    }

    func makeCoordinator() -> Coordinator_New {
        Coordinator_New(self)
    }
}
