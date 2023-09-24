
import UIKit
import Combine


/// Protocol to inform the WeatherViewController about the selected city
protocol GeoLocationsViewDelegate: AnyObject {
    func didSelect(geoLocation: GeoLocation)
}

final class GeoLocationsViewController: UITableViewController {
    var searchController: UISearchController?
    var geoLocationsViewModel = GeoLocationsViewModel()
    weak var delegate: GeoLocationsViewDelegate?
    //holds all the cancellables, used for setting up a combine based search
    var cancellables = [AnyCancellable]()
    private var fetchingTask: Task<Void, Never>?

    deinit {
        fetchingTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCombineSearch()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchingTask?.cancel()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return geoLocationsViewModel.currentGeoLocations?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return geoLocationsViewModel.currentGeoLocations?.count ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "geoLocationCell", for: indexPath)

        guard let geoLocation = getGeoLocation(for: indexPath) else { return cell }

        var geoLocationText = ""
        if let name = geoLocation.name {
            geoLocationText += name
        }
        if let state = geoLocation.state {
            geoLocationText += ","
            geoLocationText += state
        }
        if let country = geoLocation.country {
            geoLocationText += ","
            geoLocationText += country
        }

        // Configure the cell...
        cell.textLabel?.text = geoLocationText

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let geoLocation = getGeoLocation(for: indexPath) else { return }
        delegate?.didSelect(geoLocation: geoLocation)
    }
}


extension GeoLocationsViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        // Do Nothing here.
        // SetupCombineSearch takes care of performing the search
    }

    // Performs the Search using Combine
    // with a debounce logic of 200 milliseconds
    func setupCombineSearch() {
        guard let searchController = searchController else { return }
        let publisher = NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: searchController.searchBar.searchTextField)
        publisher
            .map {
                ($0.object as? UISearchTextField)?.text ?? ""
            }
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink(receiveValue: { (value) in
                self.fetchingTask = Task {
                    do {
                        let geoLocations = try await self.geoLocationsViewModel.fetchGeoLocations(city: value)
                        self.tableView.reloadData()
                        return
                    } catch {
                        // Log Error
                        // Display appropriate UI depending on the Design/UX considerations
                        print(error)
                    }
                }
            })
            .store(in: &cancellables)
    }
}

extension GeoLocationsViewController {
    func getGeoLocation(for indexPath: IndexPath) -> GeoLocation? {
        guard let geoLocations = geoLocationsViewModel.currentGeoLocations,
              geoLocations.count > 0,
              indexPath.row <= geoLocations.count else {
            return nil
        }
        return geoLocations[indexPath.row]
    }
}
