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
    @Published var hemisphere: String = "N"
    @Published var latLong: LatLong = .Latitude
    @Published var maxDegrees = 180
    
    init() {
        Location1 = Location(coordinate: CLLocationCoordinate2D(latitude: 37, longitude: -122), name: "Location 1")
        Location2 = Location(coordinate: CLLocationCoordinate2D(latitude: 37.5, longitude: -122), name: "Location 2")
        viewFormat = .DDM
        
        locations.append(Location1)
        locations.append(Location2)
        region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: (Location1.coordinate.latitude + Location2.coordinate.latitude) / 2.0,
                                                longitude: (Location1.coordinate.longitude + Location2.coordinate.longitude) / 2.0),
                span: MKCoordinateSpan(latitudeDelta: calcLatDelta(), longitudeDelta: calcLongDelta())
            )
    }
    
    fileprivate func calcLatDelta() -> CLLocationDegrees {
        let delta = abs(Location1.coordinate.latitude - Location2.coordinate.latitude) * 3
        return delta
    }

    fileprivate func calcLongDelta() -> CLLocationDegrees {
        let delta = abs(Location1.coordinate.longitude - Location2.coordinate.longitude) * 3 //1.1
        return delta
    }

    private func CalculateDistance(
        Loc1: Location,
        Loc2: Location
    ) -> String {

        let p1 = CLLocationCoordinate2D(latitude: Loc1.coordinate.latitude, longitude: Loc1.coordinate.longitude)
        let p2 = CLLocationCoordinate2D(latitude: Loc2.coordinate.latitude, longitude: Loc2.coordinate.longitude)

        let location1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
        let location2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
        let nauticalMilesPerKilometer = 0.539957
        let strDistance = String(format: "%.4f", location2.distance(from: location1) * nauticalMilesPerKilometer / 1000)
        return strDistance
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

    func getDistance() -> String {
        return CalculateDistance(Loc1: locations[0], Loc2: locations[1])
    }
    
    func getLatitute(_ index: Int) -> String {
        return DegreesToStringInSelectedFormat(degrees: locations[index].coordinate.latitude, viewFormat: viewFormat)
    }

    func getLongitute(_ index: Int) -> String {
        return DegreesToStringInSelectedFormat(degrees: locations[index].coordinate.longitude, viewFormat: viewFormat)
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

