import Foundation
import CoreLocation

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double

    init(_ location: CLLocationCoordinate2D) {
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
} 