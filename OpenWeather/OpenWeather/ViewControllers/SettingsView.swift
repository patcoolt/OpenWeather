
import SwiftUI


/// SwiftUI view to demostrate the SwiftUi and UIKit interoperability
/// This is just a demo to show the capability. This is not ideal design
struct SettingsView: View {
    var units: [MeasurementUnits] = [.imperial, .kelvin, .metric]
    @State private var selectedUnit:MeasurementUnits = MeasurementUnits(rawValue: UserDefaults.standard.string(forKey: OpenWeather.Constants.measurementUnit) ?? OpenWeather.Constants.unitsDefault.rawValue) ?? OpenWeather.Constants.unitsDefault

    var body: some View {
        VStack {
            Text("Please choose a Unit:")
            Picker("Please choose a Unit", selection: $selectedUnit) {
                ForEach(units, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .onChange(of: selectedUnit) { _ in
                UserDefaults.standard.set(self.selectedUnit.rawValue, forKey: OpenWeather.Constants.measurementUnit)
            }
            .pickerStyle(.segmented)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
