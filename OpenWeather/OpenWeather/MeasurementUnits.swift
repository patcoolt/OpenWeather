
import Foundation

enum MeasurementUnits: String {
    case imperial
    case kelvin
    case metric
    var tempSuffixLabel: String {
        switch self {
        case .imperial: return "F"
        case .kelvin: return "K"
        case .metric: return "C"
        }
    }
    var windSpeedSuffixLabel: String {
        switch self {
        case .imperial: return "mph"
        case .kelvin: return "km/h"
        case .metric: return "m/s"
        }
    }
}
