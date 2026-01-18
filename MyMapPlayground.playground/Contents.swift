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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        switch annotation.title!! {
            case "Location 1":
            annotationView.markerTintColor = UIColor.blue
            case "Location 2":
            annotationView.markerTintColor = UIColor.magenta
            case "Visitor Center":
            annotationView.markerTintColor = UIColor.red
            default:
                annotationView.markerTintColor = UIColor(red: (146.0/255), green: (187.0/255), blue: (217.0/255), alpha: 1.0)
        }
        return annotationView
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

// Create Visitor Center Annotation
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

//Create Location 1
let loc2Annotation = MKPointAnnotation()
loc2Annotation.coordinate = CLLocationCoordinate2DMake(37.338835, -122.005354)
loc2Annotation.title = "Location X"
loc2Annotation.subtitle = ""

mapView.addAnnotation(loc2Annotation)

// Create an overlay
let parkingLotPoints = [MKMapPoint(CLLocationCoordinate2DMake(37.333994, -122.005044)),
                        MKMapPoint(CLLocationCoordinate2DMake(37.333994, -122.004816)),
                        MKMapPoint(CLLocationCoordinate2DMake(37.332484, -122.004816)),
                        MKMapPoint(CLLocationCoordinate2DMake(37.332484, -122.005044))]
let parkingLotOverlay = MKPolygon(points: parkingLotPoints, count: parkingLotPoints.count)
mapView.addOverlay(parkingLotOverlay)

// Frame our annotation and overlay
mapView.camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2DMake(37.333273, -122.006581), fromDistance: 3000, pitch: 65, heading: 0)

// Add the created mapView to our Playground Live View
PlaygroundPage.current.liveView = mapView
