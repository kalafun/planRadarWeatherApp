//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import CoreData
import SwiftUI

struct WeatherDetailView: View {

    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image("Background")
                    .resizable()
                    .frame(height: 375)
            }
            .ignoresSafeArea()

            VStack {
                VStack {
                    AsyncImage(url: viewModel.weatherIconURL) { image in
                        image
                            .resizable()
                            .frame(width: 120, height: 120)
                    } placeholder: {
                        ProgressView()
                    }
                    .padding(.bottom, 50)

                    VStack(spacing: 7) {
                        infoRow("description", right: viewModel.weatherDescription)
                        infoRow("temperature", right: viewModel.temperature)
                        infoRow("humidity", right: viewModel.humidity)
                        infoRow("windspeed", right: viewModel.windSpeed)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 55)
                .padding(.bottom, 45)
                .background()
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: .black.opacity(0.2), radius: 30, y: 20)
                .padding(.horizontal, 50)
                .padding(.top, 45)

                Spacer()

                footer
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingIndicator()
            }
        }
        .navigationTitle(viewModel.cityName)
        .navigationBarTitleTextColor(Styler.Color.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton()) // Use the custom back button
        .onAppear {
            Task {
                await viewModel.getWeatherInfo()
            }
        }
    }

    private func infoRow(_ left: String, right: String) -> some View {
        HStack {
            Text(left)
                .textCase(.uppercase)
                .font(.system(size: 12, weight: .bold))
            Spacer()
            Text(right)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Styler.Color.subtitle)
        }
    }

    private var footer: some View {
        VStack {
            Text(viewModel.footerText)
                .multilineTextAlignment(.center)
                .font(.system(size: 12, weight: .regular))
            if let timeUpdatedString = viewModel.timeUpdatedString {
                Text(timeUpdatedString)
                    .font(.system(size: 12, weight: .regular))
            }
        }
    }
}

#Preview {
    let context = PersistenceController.weatherDetailPreview.container.viewContext
    let city = City(context: context)
    city.name = "Vienna"

    return NavigationStack {
        WeatherDetailView(
            viewModel: WeatherDetailView.ViewModel(
                moc: context,
                city: city
            )
        )
    }
}

extension WeatherDetailView {

    @MainActor
    class ViewModel: AppViewModel {

        // MARK: Init parameters
        let city: City
        private let moc: NSManagedObjectContext
        private let weatherService: WeatherServiceProtocol

        // MARK: Published properties
        @Published var weatherInformation: WeatherInfoResponse?
        @Published var footerText: String = ""
        @Published var timeUpdatedString: String?

        // MARK: computed properties
        var timeUpdated: Date? {
            didSet {
                timeUpdatedString = timeUpdated?.formatted(date: .numeric, time: .shortened)
            }
        }
        var cityName: String { city.name ?? "" }
        var weatherIconURL: URL? {
            guard let weatherInformation = weatherInformation,
                  let icon = weatherInformation.weather.first?.icon else { return nil }
            return URL(string: "https://openweathermap.org/img/wn/\(icon)@4x.png")
        }
        var weatherDescription: String { "\(weatherInformation?.weather.first?.description.capitalized ?? "")" }
        var temperature: String {
            guard let temperature = weatherInformation?.main.temp else { return "" }
            let celsiusTemp = kelvinToCelsius(kelvin: temperature)
            return formatTemperature(celsiusTemp)
        }
        var humidity: String { "\(weatherInformation?.main.humidity ?? 0)%"}
        var windSpeed: String { "\(weatherInformation?.wind.speed ?? 0)" + " km/h" }

        init(
            moc: NSManagedObjectContext,
            city: City,
            weatherServoce: WeatherServiceProtocol = WeatherService()
        ) {
            self.moc = moc
            self.city = city
            self.weatherService = weatherServoce
        }

        func getWeatherInfo() async {
            isLoading = true
            do {
                let response = try await weatherService.getWeatherInfo(city: cityName)
                let timeUpdated = Date()
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    print("update view")
                    self.weatherInformation = response
                    self.timeUpdated = timeUpdated
                    self.footerText = "weather information for \(cityName) received on".uppercased()
                    self.saveWeatherInfo(for: city, weatherInfo: response, tiemUpdated: timeUpdated)
                    self.isLoading = false
                }
            } catch {
                print(error)
                // TODO: Error handling
                isLoading = false
            }
        }

        private func saveWeatherInfo(for city: City, weatherInfo: WeatherInfoResponse, tiemUpdated: Date) {
            let newItem = WeatherInfo(context: moc)
            newItem.requestDate = timeUpdated
            newItem.humidity = Int16(weatherInfo.main.humidity)
            newItem.temperature = weatherInfo.main.temp
            newItem.weatherDescription = weatherInfo.weather.description
            newItem.windSpeed = weatherInfo.wind.speed
            newItem.city = city
//            city.addToWeatherInfos(newItem)

            do {
                try moc.save()
            } catch {
                print(error)
                // TODO: Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }

            print("DOne")
            // Debug print to check relationships after saving
            print("After saving:")
            fetchCityAndValidate(city: city)
        }

        private func fetchCityAndValidate(city: City) {
            let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", city.name ?? "")

            do {
                if let fetchedCity = try moc.fetch(fetchRequest).first {
                    print("Fetched City: \(fetchedCity.name ?? "No name"), Weather Infos count: \(fetchedCity.weatherInfos?.count ?? 0)")
                    if let weatherInfos = fetchedCity.weatherInfos as? Set<WeatherInfo> {
                        for info in weatherInfos {
                            print("Weather Info - Date: \(info.requestDate), Temp: \(info.temperature)")
                        }
                    }
                }
            } catch {
                print("Error fetching city: \(error)")
            }
        }


        private func kelvinToCelsius(kelvin: Float) -> Float {
            return kelvin - 273.15
        }

        private func formatTemperature(_ temperature: Float) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 1

            if let formattedTemperature = formatter.string(from: NSNumber(value: temperature)) {
                return formattedTemperature + "° C"
            } else {
                return "\(temperature)° C"
            }
        }
    }
}
