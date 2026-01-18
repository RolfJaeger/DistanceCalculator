//: A MapKit based Playground

import MapKit
import PlaygroundSupport

// Create an MKMapViewDelegate to provide a renderer for our overlay
class MapViewDelegate: NSObject, MKMapViewDelegate {
   func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       if let overlay = overlay as? MKPolygon {
           let polygonRenderer = MKPolygonRenderer(overlay: overlay)
           polygonRenderer.fillColor = UIColor(white: 0.5, alpha: 0.5)
           return polygonRenderer
       }
       return MKOverlayRenderer(overlay: overlay)
   }
}

// Create a strong reference to a delegate
let delegate = MapViewDelegate()

// Create an MKMapView
let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 800, height: 800))
mapView.delegate = delegate

// Configure The Map elevation and emphasis style
let configuration = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .default)
mapView.preferredConfiguration = configuration

// Create an annotation
let visitorCenterAnnotation = MKPointAnnotation()
visitorCenterAnnotation.coordinate = CLLocationCoordinate2DMake(37.332835, -122.005354)
visitorCenterAnnotation.title = "Visitor Center"
visitorCenterAnnotation.subtitle = "10600 N Tantau Ave"

mapView.addAnnotation(visitorCenterAnnotation)

//Create Location 1
let loc1Annotation = MKPointAnnotation()
loc1Annotation.coordinate = CLLocationCoordinate2DMake(37.335835, -122.005354)
loc1Annotation.title = "Location 1"
loc1Annotation.subtitle = ""

mapView.addAnnotation(loc1Annotation)

// Create an overlay
let parkingLotPoints = [MKMapPoint(CLLocationCoordinate2DMake(37.333994, -122.005044)),
                       MKMapPoint(CLLocationCoordinate2DMake(37.333994, -122.004816)),
                       MKMapPoint(CLLocationCoordinate2DMake(37.332484, -122.004816)),
                       MKMapPoint(CLLocationCoordinate2DMake(37.332484, -122.005044))]
let parkingLotOverlay = MKPolygon(points: parkingLotPoints, count: parkingLotPoints.count)
mapView.addOverlay(parkingLotOverlay)

// Frame our annotation and overlay
mapView.camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2DMake(37.333273, -122.006581), fromDistance: 3000, pitch: 10, heading: 0)


