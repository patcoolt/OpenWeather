
import Foundation


/// Weather View Model
@MainActor
final class WeatherViewModel {
    private let urlBuilder: URLBuilder
    private let networkService: NetworkService
    private let userDefaults: UserDefaults

    var latCurrent: Double
    var lonCurrent: Double
    var measurementUnitsCurrent: MeasurementUnits = OpenWeather.Constants.unitsDefault
    
    init(urlBuilder: URLBuilder = URLBuilder(),
         networkService: NetworkService = NetworkService(),
         userDefaults: UserDefaults = UserDefaults.standard) {
        self.urlBuilder = urlBuilder
        self.networkService = networkService
        self.userDefaults = userDefaults

        if let lat = userDefaults.object(forKey: OpenWeather.Constants.lat) as? Double,
           let lon = userDefaults.object(forKey: OpenWeather.Constants.lon) as? Double {
            latCurrent = lat
            lonCurrent = lon
        } else {
            latCurrent = OpenWeather.Constants.latDefault
            lonCurrent = OpenWeather.Constants.lonDefault
        }

        updateLatLon(lat: latCurrent, lon: lonCurrent)
        measurementUnitsCurrent = MeasurementUnits(rawValue: userDefaults.string(forKey: OpenWeather.Constants.measurementUnit) ?? MeasurementUnits.imperial.rawValue) ?? OpenWeather.Constants.unitsDefault
    }

    func fetchWeather() async  throws -> WeatherInfo? {
        do {
            let measurementUnit = MeasurementUnits(rawValue: userDefaults.string(forKey: OpenWeather.Constants.measurementUnit) ?? OpenWeather.Constants.unitsDefault.rawValue) ?? OpenWeather.Constants.unitsDefault
            let queryItems = [
                URLQueryItem(name: URLBuilder.Constants.units, value: measurementUnit.rawValue),
                URLQueryItem(name: URLBuilder.Constants.lat, value: String(latCurrent)),
                URLQueryItem(name: URLBuilder.Constants.lon, value: String(lonCurrent))
            ]
            guard let url = self.urlBuilder.url(endpoint: .weather, queryItems: queryItems) else {
                throw URLError(.badURL)
            }
            return try await networkService.fetchWeather(url: url)
        } catch {
            throw error
        }
    }
}

extension WeatherViewModel {
    func convertTempToDisplayText(temperature: Double?) -> String {
        guard let temperature else { return "NA" }
        return String(temperature) + " ° " + measurementUnitsCurrent.tempSuffixLabel
    }

    func convertWindDirectionToDisplayText(direction: Int?) -> String? {
        guard let direction else { return nil }
        return OpenWeather.Constants.WindDirectionTable[direction]
    }

    func isLatLonChanged(lat: Double, lon: Double) -> Bool {
        latCurrent != lat || lonCurrent != lon
    }

    func updateLatLon(lat: Double, lon: Double) {
        latCurrent = lat
        lonCurrent = lon

        userDefaults.set(latCurrent, forKey: OpenWeather.Constants.lat)
        userDefaults.set(lonCurrent, forKey: OpenWeather.Constants.lon)
    }

    func isUnitsMeasurementChanged() -> Bool {
        let unitsMeasurement = MeasurementUnits(rawValue: userDefaults.string(forKey: OpenWeather.Constants.measurementUnit) ?? OpenWeather.Constants.unitsDefault.rawValue) ?? OpenWeather.Constants.unitsDefault

        return unitsMeasurement != measurementUnitsCurrent
    }

    func updateUnitsMeasurement() {
        measurementUnitsCurrent = MeasurementUnits(rawValue: userDefaults.string(forKey: OpenWeather.Constants.measurementUnit) ?? OpenWeather.Constants.unitsDefault.rawValue) ?? OpenWeather.Constants.unitsDefault
    }
}
