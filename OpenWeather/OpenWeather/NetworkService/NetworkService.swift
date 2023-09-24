
import Foundation

enum APIError: String, Error {
    case fetchDataFailure = "Error Fetching Data"
}

protocol APIServiceProtocol {
    func fetchWeather(url: URL) async throws -> WeatherInfo?
    func fetchGeoLocations(url: URL) async throws -> [GeoLocation]?
}

class NetworkService: APIServiceProtocol {
    private let urlSession: URLSession
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func fetchWeather(url: URL) async throws -> WeatherInfo? {
        do {
            guard let data = try await self.fetchData(url: url) else {
                throw APIError.fetchDataFailure
            }
            return try JSONDecoder().decode(WeatherInfo.self, from: data)
        } catch {
            throw error
        }
    }

    func fetchGeoLocations(url: URL) async throws -> [GeoLocation]? {
        do {
            guard let data = try await self.fetchData(url: url) else {
                throw APIError.fetchDataFailure
            }
            return try JSONDecoder().decode([GeoLocation].self, from: data)
        } catch {
            throw error
        }
    }
}

private extension NetworkService {

    func fetchData(url: URL) async throws -> Data? {
        do {
            print("url = \(url)")
            let (data, response) = try await urlSession.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
    func handleResponse(data: Data?, response: URLResponse?) -> Data? {
        guard
            let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
                return nil
            }
        return data
    }
}
