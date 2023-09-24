
import Foundation

public enum OpenWeather {

}

public extension OpenWeather {
    /// various UnifiedEvents Constants
    enum Constants {
        static let lat = "latKey"
        static let lon = "lonKey"
        static let measurementUnit = "MeasurementUnitKey"
        static let latDefault = 37.4443293  // Default Latitude, Palo Alto, CA
        static let lonDefault = -122.1598465  // Default Longitude, Palo Alto, CA
        static let unitsDefault: MeasurementUnits = .imperial
        static let SearchLimitDefault = "5"
        static let WindDirectionTable = [10:"N",
                                         20:"N/NE",
                                         30:"N/NE",
                                         40:"NE",
                                         50:"NE",
                                         60:"E/NE",
                                         70:"E/NE",
                                         80:"E",
                                         90:"E",
                                         100:"E",
                                         110:"E/SE",
                                         120:"E/SE",
                                         130:"SE",
                                         140:"SE",
                                         150:"S/SE",
                                         160:"S/SE",
                                         170:"S",
                                         180:"S",
                                         190:"S",
                                         200:"S/SW",
                                         210:"S/SW",
                                         220:"SW",
                                         230:"SW",
                                         240:"W/SW",
                                         250:"W/SW",
                                         260:"W",
                                         270:"W",
                                         280:"W",
                                         290:"W/NW",
                                         300:"W/NW",
                                         310:"NW",
                                         320:"NW",
                                         330:"N/NW",
                                         340:"N/NW",
                                         350:"N",
                                         360:"N"
                 ]
    }
}
