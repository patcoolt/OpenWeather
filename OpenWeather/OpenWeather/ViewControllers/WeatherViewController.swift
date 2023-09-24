
import UIKit
import Combine
import SwiftUI
import CoreLocation
import Kingfisher

final class WeatherViewController: UIViewController {
    /// activity indicator spinner view to display while UI is initializing
    var spinnerViewController: SpinnerViewController? = nil
    /// location manager
    var locationManager: CLLocationManager?
    /// weather view model
    let weatherViewModel = WeatherViewModel()

    /// UI Search Controller used to enter the search city name
    var searchController = UISearchController(searchResultsController: nil)

    /// Geo Locations Results View Controller, used by the SearchController
    var geoLocationsViewController: GeoLocationsViewController!

    @IBOutlet var stackViewBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet var stackView: UIStackView!

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureMinLabel: UILabel!
    @IBOutlet weak var temperatureMaxLabel: UILabel!
    
    @IBOutlet weak var visibilityLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Search Controller
        setupGeoLocationsSearchViewController()
        // Setup the UI based on the size class
        traitCollectionDidChange(self.traitCollection)

        // Setup the Location Manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest

        // Shows the spinner view while UI is setup
        // Temp Work around, would like to have a better design here
        addSpinnerView()

        // load weather for the last loaded sity
        fetchWeather()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // If the Units of Measurement changed in the settings view, Fetch the weather information again
        if weatherViewModel.isUnitsMeasurementChanged() {
            weatherViewModel.updateUnitsMeasurement()
            fetchWeather()
        }
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Sets up the UI per the size classes
        switch traitCollection.verticalSizeClass {
        case .regular, .unspecified:
            stackViewBottomMarginConstraint.constant = 100
            stackView.axis = .vertical
        case .compact:
            stackViewBottomMarginConstraint.constant = 5
            stackView.axis = .horizontal
        @unknown default:
            stackViewBottomMarginConstraint.constant = 100
            stackView.axis = .vertical
        }
    }
}

extension WeatherViewController {
    /// Shows the Settings UI
    /// This is a SwiftUI view, demonstrating the UIKit and SwiftUI interoperability
    @IBAction func showSettings(sender: UIBarButtonItem) {
        let vc = UIHostingController(rootView: SettingsView())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

private extension WeatherViewController {
    /// Adds the Spinner Activity View as a child view controller
    func addSpinnerView() {
        let spinnerVC = SpinnerViewController()

        // add the spinner view controller
        addChild(spinnerVC)
        spinnerVC.view.frame = view.frame
        view.addSubview(spinnerVC.view)
        spinnerVC.didMove(toParent: self)
        self.spinnerViewController = spinnerVC
    }


    /// Removes the Spinner Activity View child view controller
    func removeSpinnerView() {
        guard let spinnerVC = spinnerViewController else { return }
        spinnerVC.willMove(toParent: nil)
        spinnerVC.view.removeFromSuperview()
        spinnerVC.removeFromParent()
        spinnerViewController = nil
    }

    /// Sets up the UISearchController for performing search
    func setupGeoLocationsSearchViewController() {
        guard let storyboard else { return }
        geoLocationsViewController = storyboard.instantiateViewController(withIdentifier: "geoLocationsViewController") as? GeoLocationsViewController
        geoLocationsViewController.delegate = self
        searchController = UISearchController(searchResultsController: geoLocationsViewController)
        searchController.searchResultsUpdater = geoLocationsViewController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type something here to search"
        geoLocationsViewController.searchController = searchController

        navigationItem.searchController = searchController
    }
    /// Displays the Wind UI
    func displayWind(weatherInfo: WeatherInfo?) {
        var windText = ""
        if let speed = weatherInfo?.wind?.speed {
            windText = String(speed)
            windText += weatherViewModel.measurementUnitsCurrent.windSpeedSuffixLabel
        }
        if let direction = weatherInfo?.wind?.deg {
            windText += " "
            windText += weatherViewModel.convertWindDirectionToDisplayText(direction: direction) ?? ""
        }
        windSpeedLabel.text = windText
    }

    /// Displays the Weather UI
    func displayWeather(weatherInfo: WeatherInfo?) {
        var cityText = weatherInfo?.name ?? ""
        // Show country data if present
        if let country = weatherInfo?.sys?.country {
            cityText += ","
            cityText += country
        }

        cityLabel.text = cityText

        displayWind(weatherInfo: weatherInfo)

        // Show pressure data if present
        if let pressure = weatherInfo?.main?.pressure {
            pressureLabel.text = String(pressure) + "hPa"
        } else {
            pressureLabel.text = "NA"
        }
        // Show humidity data if present
        if let humidity = weatherInfo?.main?.humidity {
            humidityLabel.text = String(humidity) + "%"
        } else {
            humidityLabel.text = "NA"
        }
        // Displays the Temperature info
        temperatureLabel.text = weatherViewModel.convertTempToDisplayText(temperature: weatherInfo?.main?.temp)
        // Displays the Minimum Temperature info
        temperatureMinLabel.text = weatherViewModel.convertTempToDisplayText(temperature: weatherInfo?.main?.tempMin)
        // Displays the Maximum Temperature info
        temperatureMaxLabel.text = weatherViewModel.convertTempToDisplayText(temperature: weatherInfo?.main?.tempMax)

        // Show visibility data if present
        if let visibility = weatherInfo?.visibility {
            visibilityLabel.text = String(visibility) + "km"
        } else {
            visibilityLabel.text = "NA"
        }

        if let weather = weatherInfo?.weather,
           weather.count > 0 {
            var feelsLikeText = "Feels Like "
            feelsLikeText += weatherViewModel.convertTempToDisplayText(temperature: weatherInfo?.main?.feelsLike)
            feelsLikeText += ","
            // First entry is the primary weather info
            feelsLikeText += weather.first?.description ?? ""
            descriptionLabel.text = feelsLikeText

            if let icon = weather.first?.icon {
                let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
                weatherImageView.kf.setImage(with: url)
            }
        } else {
            descriptionLabel.text = "NA"
        }
    }
}

private extension WeatherViewController {
    /// Performs the async fetch operation using the viewmodel
    func fetchWeather() {
        Task {
            do {
                defer {
                    removeSpinnerView()
                }
                guard let weatherInfo = try await weatherViewModel.fetchWeather() else {
                    print("Error - weather data not fetched")
                    return
                }
                displayWeather(weatherInfo: weatherInfo)
            } catch {
                // Log Error
                // Display appropriate UI depending on the Design/UX considerations
                print(error)
            }
        }
    }
}


extension WeatherViewController:  CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("location access restricted")
            // Inform user about the restriction
            break
        case .denied:
            print("location access authorization denied")
            // The user denied the use of location services for the app or they are disabled globally in Settings.
            // Direct them to re-enable this.
            break
        case .authorizedAlways, .authorizedWhenInUse:
            print("location access authorized")
            manager.requestLocation()
        @unknown default:
            print("unknown location authorization")
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.first,
           weatherViewModel.isLatLonChanged(lat: location.coordinate.latitude, lon: location.coordinate.longitude) {
            weatherViewModel.updateLatLon(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            // Load the weather for the current location
            fetchWeather()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location access failed \(error)")
    }
}

// MARK: -

extension WeatherViewController: GeoLocationsViewDelegate {

    /// Delegate callback from the GeoLocations Search View Controller.
    /// User selected a city, use the lat lon to fetch the weather
    func didSelect(geoLocation: GeoLocation) {
        searchController.isActive = false
        guard let lat = geoLocation.lat,
              let lon = geoLocation.lon,
              weatherViewModel.isLatLonChanged(lat: lat, lon: lon) else {
            return
        }
        weatherViewModel.updateLatLon(lat: lat, lon: lon)
        // Load weather for the selected location
        fetchWeather()
    }
}
