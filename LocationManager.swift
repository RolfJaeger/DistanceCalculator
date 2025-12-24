//
//  LocationManager.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 3/5/25.
//

import Foundation
import CoreLocation
import MapKit

let mphToKts = 0.869 //1.94384
var magneticVariation = +13.0 //East

struct UserLocation: Identifiable, Equatable {
    let id = UUID() // Unique ID for each annotation
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: UserLocation, rhs: UserLocation) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var userLocations: [UserLocation] = []
    @Published var userHeading: Double = 0.0 //: Double = 0.0
    @Published var userCourse: Double = 0.0 //: Double = 0.0
    @Published var direction: CLLocationDirection = .zero
    @Published var location: CLLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 51.500685, longitude: -0.124570), altitude: .zero, horizontalAccuracy: .zero, verticalAccuracy: .zero, timestamp: Date.now)
    
    private var locationManager = CLLocationManager()
    var lastKnownLocation: CLLocation?
    var userSpeedInKnots: Double?
    var cameraDistance: Double = 2000.0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lastKnownLocation = location
            userSpeedInKnots = location.speed * mphToKts
            userCourse = location.course
            DispatchQueue.main.async {
                self.userLocations = [UserLocation(coordinate: location.coordinate)]
            }
        }
        locations.forEach { [weak self] location in
            Task { @MainActor [weak self]  in
                self?.location = location
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.userHeading = newHeading.trueHeading // Heading in degrees
        }
        Task { @MainActor [weak self]  in
            self?.direction = newHeading.trueHeading
        }
    }
    
    func UserVectorCoordinates(_ lengthOfCourseVector: Double) -> [CLLocationCoordinate2D] {
        if self.lastKnownLocation != nil {
            let userLocation = CLLocationCoordinate2D(latitude: (self.lastKnownLocation?.coordinate.latitude)!, longitude: (self.lastKnownLocation?.coordinate.longitude)!)
            let distance = lengthOfCourseVector
            let targetLocation =  self.LocationAtDistanceAndBearing(refLoc: userLocation, distance: distance, bearing: self.userCourse)
            return [userLocation, targetLocation]
        }
        else {
            return []
        }
    }

    func getTrueBearingToLocation(_ location: CLLocationCoordinate2D) -> String {
        if let userLocation = lastKnownLocation {
            var trueBearing = Bearing(from: userLocation, to: CLLocation(latitude: location.latitude, longitude: location.longitude))
            if trueBearing < 0 {
                trueBearing = trueBearing + 360
            }
            trueBearing = TruncateToSpecifiedNumberOfDigits(trueBearing, n: 0)
            return String(trueBearing)
        }
        else {
            return "N/A"
        }
    }
    
    func getMagBearingToLocation(_ location: CLLocationCoordinate2D) -> String {
        if let userLocation = lastKnownLocation {
            let trueBearing = Bearing(from: userLocation, to: CLLocation(latitude: location.latitude, longitude: location.longitude))
            var magneticBearing = trueBearing - magneticVariation
            if magneticBearing < 0 {
                magneticBearing = magneticBearing + 360
            }
            magneticBearing = TruncateToSpecifiedNumberOfDigits(magneticBearing, n: 1)
            return String(magneticBearing)
        }
        else {
            return "N/A"
        }
    }
    
    private func TruncateToSpecifiedNumberOfDigits(_ value: Double, n: Int) -> Double {
        return Double(floor(pow(10.0, Double(n)) * value)/pow(10.0, Double(n)))
    }

    func getDistanceToLocationInFeet(_ location: CLLocationCoordinate2D) -> String {
        if let userLocation = lastKnownLocation {
            let feetPerMeter = 3.28084
            let sbLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distanceInMeters = sbLocation.distance(from: userLocation)
            let distanceInNauticalMiles = distanceInMeters * feetPerMeter
            let d = TruncateToSpecifiedNumberOfDigits(distanceInNauticalMiles, n: 1)
            return String(d)
        }
        else {
            return "N/A"
        }
    }
    
    func getDistanceToLocationInMeters(_ location: CLLocationCoordinate2D) -> String {
        if let userLocation = lastKnownLocation {
            let sbLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distanceInMeters = sbLocation.distance(from: userLocation)
            let d = TruncateToSpecifiedNumberOfDigits(distanceInMeters, n: 1)
            return String(d)
        }
        else {
            return "N/A"
        }
    }

    private func Bearing(from: CLLocation, to: CLLocation) -> Double {
        // Returns a float with the angle between the two points
        var x: CLLocationDegrees
        if from.coordinate.longitude < 0 {
            x = -from.coordinate.longitude + to.coordinate.longitude
        }
        else {
            x = from.coordinate.longitude - to.coordinate.longitude
        }
        let y = from.coordinate.latitude - to.coordinate.latitude
        
        return fmod(XXRadiansToDegrees(radians: atan2(y, x)), 360.0) + 90.0
    }

    private func XXRadiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / Double.pi
    }
    
    func LocationAtDistanceAndBearing(refLoc: CLLocationCoordinate2D, distance: Double, bearing: CLLocationDegrees) -> CLLocationCoordinate2D {
        let R = 3958.8 * 5280.0 //miles * feet
        let lat = AngleInRadians(refLoc.latitude)
        let long = AngleInRadians(refLoc.longitude)
        let bearingInRadians = AngleInRadians(bearing)
        let distNorth = distance * cos(bearingInRadians)
        let distEast = distance * sin(bearingInRadians)
        
        let deltaLat = distNorth/R
        let newLat = (lat + deltaLat) * (180.0/Double.pi)
        
        let deltaLong = distEast/(R * cos(lat))
        let newLong = (long + deltaLong) * (180.0/Double.pi)
        return CLLocationCoordinate2D(latitude: newLat, longitude: newLong)
    }
    
    fileprivate func AngleInRadians(_ angle: Double) -> Double {
        return angle * (Double.pi/180)
    }
    
    fileprivate func LineBearing(courseAxis: CLLocationDegrees, side: String) -> CLLocationDegrees {
        var lineBearing: CLLocationDegrees
        switch side {
        case "Stb":
            lineBearing = courseAxis + 90.0
        default:
            lineBearing = courseAxis - 90.0
        }
        if lineBearing < 0 {
            return lineBearing + 360.0
        }
        else if lineBearing > 360.0 {
            return lineBearing - 360.0
        }
        else {
            return lineBearing
        }
    }
    
    fileprivate func ReciprocalBearing(_ bearing: CLLocationDegrees) -> CLLocationDegrees {
        var reciprocalBearing: CLLocationDegrees = bearing + 180
        if reciprocalBearing > 360 {
            reciprocalBearing = reciprocalBearing - 360
        }
        return reciprocalBearing
    }
    

}
