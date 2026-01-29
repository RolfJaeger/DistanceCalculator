//
//  TestOfDraggableMapView.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 1/27/26.
//

import SwiftUI
import CoreLocation
import MapKit

class CustomAnnotationView_Rev1 : MKPinAnnotationView
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


final class Coordinator_Rev1: NSObject, MKMapViewDelegate {

    var parent: DraggableMapView_Rev1
    private var annotations: [UUID: MKPointAnnotation] = [:]

    init(_ parent: DraggableMapView_Rev1) {
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

        let view = CustomAnnotationView_Rev1(annotation: annotation, reuseIdentifier: nil)
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

        if let index = parent.locations.firstIndex(where: {
            annotations[$0.id] === view.annotation
        }) {
            parent.locations[index].coordinate = coord
            parent.strDistance = CalculateDistance(Loc1: parent.locations[0], Loc2: parent.locations[1])

            
        }

        view.dragState = .none
    }
}

struct DraggableMapView_Rev1: UIViewRepresentable {

    @Binding var locations: [Location]
    @Binding var strDistance: String
    var region: MKCoordinateRegion?
    
    init(locations: Binding<[Location]>, strDistance: Binding<String>, region: MKCoordinateRegion? = nil) {
        _locations = locations
        _strDistance = strDistance
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: calcLatCenter(), longitude: calcLongCenter()),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    }
    
    fileprivate func calcLatCenter() -> CLLocationDegrees {
        let center = (locations[0].coordinate.latitude + locations[1].coordinate.latitude)/2.0
        return center
    }

    fileprivate func calcLongCenter() -> CLLocationDegrees {
        let center = (locations[0].coordinate.longitude + locations[1].coordinate.longitude) / 2.0
        return center
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region!
        mapView.addAnnotations(locations.map { context.coordinator.annotation(for: $0) })
        return mapView
    }
    
    /*
    func convertMapCameraPositionToMKCoordinateRegion(region: MapCameraPosition) -> MKCoordinateRegion {
        let lat = region.camera?.centerCoordinate.latitude ?? 0.0
        let long = region.camera?.centerCoordinate.longitude ?? 0.0
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let convertedRegion = MKCoordinateRegion(center: center, span: span)
        return convertedRegion
    }
    */
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        //TODO: Update the locations here using mapView.annotations[0].coordinate and ... [1].coordinate
    }

    func makeCoordinator() -> Coordinator_Rev1{
        Coordinator_Rev1(self)
    }
}


struct TestOfDraggableMapView: View {

    @State private var locations: [Location] = [
        Location(coordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090), name: "Location 1"),
        Location(coordinate: CLLocationCoordinate2D(latitude: 37.4, longitude: -122.0090), name: "Location 2"),
    ]
    
    @State private var strDistance = "0.0"

    var body: some View {
        DraggableMapView_Rev1(locations: $locations, strDistance: $strDistance, region: nil)
            .ignoresSafeArea()
    }
}

#Preview {
    TestOfDraggableMapView()
}
