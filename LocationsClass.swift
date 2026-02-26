//
//  LocationsClass.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 2/15/26.
//

import Foundation
import Combine
import CoreLocation
import MapKit

class LocationObject: ObservableObject {
    // @Published automatically announces changes to this property
    @Published var Location1: Location
    @Published var Location2: Location
    @Published var locations: [Location] = [Location]()
    @Published var region: MKCoordinateRegion?
    @Published var viewFormat: ViewFormat
    @Published var hemisphere: String = "W"
    @Published var latLong: LatLong = .Longitude
    @Published var maxDegrees = 180
    @Published var strDistance = "0.0"
    @Published var bReturningFromMapView = false
    @Published var doneWithInitialization = false
    //This is a crutch masking the bug that locations from the LocationDBView are only transferred to DistanceView after the LocationsOnMap view was visited
    
    
    init() {
        Location1 = Location(coordinate: CLLocationCoordinate2D(latitude: 37, longitude: -122), name: "Location 1")
        Location2 = Location(coordinate: CLLocationCoordinate2D(latitude: 37.5, longitude: -122), name: "Location 2")
        viewFormat = .DDM
        
        locations.append(Location1)
        locations.append(Location2)
        strDistance = CalculateDistance()
    }

    func initializeLocationsWithCurrentLocation(currentLocation: CLLocationCoordinate2D) {
        let newLocation1 = Location(coordinate: currentLocation, name: "Location 1")
        let newLocation2 = Location(coordinate: currentLocation, name: "Location 2")
        locations = [Location]()
        locations.append(newLocation1)
        locations.append(newLocation2)
        strDistance = CalculateDistance()
        region = setRegion()
    }

    func setLocationToCurrentLocation(currentLocation: CLLocationCoordinate2D, locIndex: Int) {
        locations[locIndex].coordinate.latitude = currentLocation.latitude.rounded(toPlaces: 3)
        locations[locIndex].coordinate.longitude = currentLocation.longitude.rounded(toPlaces: 3)
        strDistance = CalculateDistance()
        region = setRegion()
    }
    
    private func calcLatDelta() -> CLLocationDegrees {
        if locations[0].coordinate.latitude - locations[1].coordinate.latitude == 0 {
            return 1.0
        }
        let delta = abs(locations[0].coordinate.latitude - locations[1].coordinate.latitude) * 1.5
        return delta
    }

    private func calcLongDelta() -> CLLocationDegrees {
        if locations[0].coordinate.longitude - locations[1].coordinate.longitude == 0 {
            return 1.0
        }
        let delta = abs(locations[0].coordinate.longitude - locations[1].coordinate.longitude) * 1.5 //1.1
        return delta
    }

    private func CalculateDistance() -> String {

        let p1 = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let p2 = CLLocationCoordinate2D(latitude: locations[1].coordinate.latitude, longitude: locations[1].coordinate.longitude)

        if p1.latitude == p2.latitude && p1.longitude == p2.longitude {
            return "0.0000 nm"
        } else {
            let location1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
            let location2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
            let nauticalMilesPerKilometer = 0.539957
            let distance = location2.distance(from: location1) * nauticalMilesPerKilometer / 1000
            var strDistance: String
            if distance > 5000 {
                strDistance = "Too Large"
            } else {
                strDistance = String(format: "%.4f", distance) + " nm"
            }
            return strDistance
        }
    }

    func getNorthSouth(_ index: Int) -> String {
        if locations[index].coordinate.latitude > 0 {
            return "N"
        } else {
            return "S"
        }
    }

    func getEastWest(_ index: Int) -> String {
        if locations[index].coordinate.longitude > 0 {
            return "E"
        } else {
            return "W"
        }
    }

    func setHemisphere(locIndex: Int) {
        let loc = locations[locIndex]
        if latLong == .Latitude {
            hemisphere = loc.coordinate.latitude >= 0 ? "N" : "S"
        } else {
            hemisphere = loc.coordinate.longitude >= 0 ? "E" : "W"
        }
    }
    
    func switchHemisphere(locIndex: Int) {
        switch hemisphere {
        case "N":
            hemisphere = "S"
            locations[locIndex].coordinate.latitude = -locations[locIndex].coordinate.latitude
        case "S":
            hemisphere = "N"
            locations[locIndex].coordinate.latitude = -locations[locIndex].coordinate.latitude
        case "E":
            hemisphere = "W"
            locations[locIndex].coordinate.longitude = -locations[locIndex].coordinate.longitude
        default:
            hemisphere = "E"
            locations[locIndex].coordinate.longitude = -locations[locIndex].coordinate.longitude
        }
        strDistance = CalculateDistance()
        region = setRegion()
    }
    
    func getLatitute(_ index: Int) -> String {
        return DegreesToStringInSelectedFormat(degrees: locations[index].coordinate.latitude, viewFormat: viewFormat)
    }

    func getLongitute(_ index: Int) -> String {
        return DegreesToStringInSelectedFormat(degrees: locations[index].coordinate.longitude, viewFormat: viewFormat)
    }
    
    func updateLocations(loc1: Location, loc2: Location) {
        let newLoc1 = Location(coordinate: loc1.coordinate, name: loc1.name)
        let newLoc2 = Location(coordinate: loc2.coordinate, name: loc2.name)
        locations = [Location]()
        locations.append(newLoc1)
        locations.append(newLoc2)
        strDistance = CalculateDistance()
        region = setRegion()
    }
    
    func updateLocation(newDegrees: Double, locIndex: Int) {
        var newValue = newDegrees
        if hemisphere == "S" || hemisphere == "W" {
            newValue = -newValue
        }
        if latLong == .Latitude {
            locations[locIndex].coordinate.latitude = newValue
        } else {
            locations[locIndex].coordinate.longitude = newValue
        }
        strDistance = CalculateDistance()
        region = setRegion()
    }
    
    func setToNewLocation(newLocation: Location, locIndex: Int) {
        locations[locIndex] = newLocation
        strDistance = CalculateDistance()
        region = setRegion()
    }
    
    func updateLocations(indexToUpdate: Int, newLocation: CLLocationCoordinate2D) {
        let newLocation = Location(coordinate: newLocation, name: locations[indexToUpdate].name)
        var newLocations = [Location]()
        switch indexToUpdate {
        case 1:
            newLocations.append(locations[0])
            newLocations.append(newLocation)
        default:
            newLocations.append(newLocation)
            newLocations.append(locations[1])
        }
        locations = [Location]()
        locations.append(newLocations[0])
        locations.append(newLocations[1])
        strDistance = CalculateDistance()
        region = setRegion()
    }
    
    private func setRegion() -> MKCoordinateRegion {
        let region =             MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (locations[0].coordinate.latitude + locations[1].coordinate.latitude) / 2.0,
                                            longitude: (locations[0].coordinate.longitude + locations[1].coordinate.longitude) / 2.0),
            span: MKCoordinateSpan(latitudeDelta: calcLatDelta(), longitudeDelta: calcLongDelta())
        )
        return region
    }

    private func DegreesToStringInSelectedFormat(degrees: CLLocationDegrees, viewFormat: ViewFormat) -> String {
        var strDegrees: String
        switch viewFormat {
        case .DMS:
            strDegrees = DegreesInDMS(degrees: degrees)
        case .DDM:
            strDegrees = DecimalDegrees(degrees: degrees)
        case .Raymarine:
            strDegrees = DegreesInRaymarineFormat(degrees: degrees)
        }
        return strDegrees
    }

    private func DegreesInDMS(degrees: CLLocationDegrees) -> String {
        let degreesWithoutSign = degrees < 0 ? -degrees : degrees
        var d = Int(degreesWithoutSign)
        var fractualMinutes = (degreesWithoutSign - Double(d)) * 60
        if fractualMinutes == 60 {
            d += 1
            fractualMinutes = 0
        }
        var m = Int(fractualMinutes)
        var doubleSeconds = Double((fractualMinutes - Double(m))*60).rounded(toPlaces: 0)
        if doubleSeconds == 60 {
            m += 1
            doubleSeconds = 0
        }
        let s = Int(doubleSeconds.rounded(toPlaces: 0))
        return "\(d)\u{00B0} \(m)' \(s)\""
    }

    private func DecimalDegrees(degrees: CLLocationDegrees) -> String {
        var decimalDegrees = Double(degrees).rounded(toPlaces: 4)
        if decimalDegrees < 0 {
            decimalDegrees = -decimalDegrees
        }
        return "\(decimalDegrees)\u{00B0}"
    }

    private func DegreesInRaymarineFormat(degrees: CLLocationDegrees) -> String {
        var d = Int(degrees)
        var fractualMinutes = Double((degrees - Double(d)) * 60).rounded(toPlaces: 3)
        if degrees < 0 {
            d = -d
            if fractualMinutes < 0 {
                fractualMinutes = -fractualMinutes
            }
        }
        return "\(d)\u{00B0} \(fractualMinutes)'"
    }

}
