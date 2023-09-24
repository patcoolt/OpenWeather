
import Foundation
@MainActor
final class GeoLocationsViewModel {
    let urlBuilder: URLBuilder
    let networkService: NetworkService
    var currentCity: String
    var currentGeoLocations: [GeoLocation]? = [GeoLocation]()

    init(urlBuilder: URLBuilder = URLBuilder(),
         networkService: NetworkService = NetworkService()) {
        self.urlBuilder = urlBuilder
        self.networkService = networkService
        self.currentCity = ""
    }

    func fetchGeoLocations(city: String) async  throws -> [GeoLocation]? {
        do {
            guard !city.isEmpty else { return nil }
            if city == currentCity { return currentGeoLocations }
            let queryItems = [
                URLQueryItem(name: URLBuilder.Constants.q, value: city)
            ]
            guard let url = self.urlBuilder.url(endpoint: .geoLocation, queryItems: queryItems) else {
                throw URLError(.badURL)
            }
            self.currentGeoLocations = try await networkService.fetchGeoLocations(url: url)
            return self.currentGeoLocations
        } catch {
            throw error
        }
    }
}
