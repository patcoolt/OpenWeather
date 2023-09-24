
import Foundation

struct URLBuilder {
    enum Path: String {
        case weather = "data/2.5/weather"
        case geoLocation = "geo/1.0/direct"
    }

    func url(endpoint: Path, queryItems: [URLQueryItem]) -> URL? {
        switch endpoint {
        case .weather:
            return construct( path: "/\(endpoint.rawValue)", queryItems: queryItems)
        case .geoLocation:
            let queryItemsGeo = [
                URLQueryItem(name: URLBuilder.Constants.limit, value: OpenWeather.Constants.SearchLimitDefault)
            ] + queryItems
            return construct(path: "/\(endpoint.rawValue)", queryItems: queryItemsGeo)
        }
    }

    func construct( path: String, queryItems: [URLQueryItem] = []) -> URL? {
        var components = URLComponents()
        components.scheme = URLBuilder.Constants.scheme
        components.host = URLBuilder.Constants.host
        components.path = path
        let defaultQueryItems = defaultQueryItems()
        components.queryItems = defaultQueryItems + queryItems
        return components.url
    }
}

extension URLBuilder {
    func defaultQueryItems() -> [URLQueryItem] {
        var queryitems = [URLQueryItem]()
        queryitems.append(URLQueryItem(name: URLBuilder.Constants.appId, value: URLBuilder.Constants.appIdKeyValue))
        return queryitems
    }
}

// MARK: - Strings -

extension URLBuilder {
    enum Constants {
        static let appId = "appid"
        static let units = "units"
        static let lat = "lat"
        static let lon = "lon"
        static let q = "q"
        static let limit = "limit"
        static let imperial = "imperial"
        static let standard = "standard"
        static let metric = "metric"

        static let scheme = "https"
        static let host = "api.openweathermap.org"
        static let appIdKeyValue = "ec628fb550bf8969ff413b56326e0742"
        static let hostKeyValue = "ec628fb550bf8969ff413b56326e0742"
    }
}
