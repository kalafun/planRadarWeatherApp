//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import CoreData
import SwiftUI

struct WeatherDetailView: View {

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
            Text(viewModel.timeUpdatedString)
                .font(.system(size: 12, weight: .regular))
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
        var city: City
        private let moc: NSManagedObjectContext
        private let weatherService: WeatherServiceProtocol

        // MARK: Published properties
        @Published var weatherInfoResponse: WeatherInfoResponse?

        @Published var footerText: String = ""
        var timeUpdated: Date?

        // MARK: computed properties
        var cityName: String {
            city.name ?? ""
        }
        var timeUpdatedString: String {
            timeUpdated?.formatted(date: .numeric, time: .shortened) ?? ""
        }

        var weatherIconURL: URL? {
            guard let weatherInformation = weatherInfoResponse,
                  let icon = weatherInformation.weather.first?.icon else { return nil }
            return URL(string: "https://openweathermap.org/img/wn/\(icon)@4x.png")
        }
        var weatherDescription: String {
            weatherInfoResponse?.weather.first?.description.capitalized ?? ""
        }
        var temperature: String {
            guard let temperature = weatherInfoResponse?.main.temp else { return "" }
            return WeatherFormatter.formatTemperature(temperature)
        }
        var humidity: String {
            "\(weatherInfoResponse?.main.humidity ?? 0)%"
        }
        var windSpeed: String {
            "\(weatherInfoResponse?.wind.speed ?? 0)" + " km/h"
        }

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
                    print("update view")
                    self.weatherInfoResponse = response
                    self.timeUpdated = timeUpdated
                    self.footerText = "weather information for \(cityName) received on".uppercased()
                    saveWeatherInfo(for: city, weatherInfo: weatherInfoResponse!, tiemUpdated: timeUpdated)
                    self.isLoading = false
            } catch {
                print(error)
                // TODO: Error handling
                isLoading = false
            }
        }

        func saveWeatherInfo(for city: City, weatherInfo: WeatherInfoResponse, tiemUpdated: Date) {
            let newItem = WeatherInfo(context: moc)
            newItem.requestDate = timeUpdated
            newItem.humidity = Int16(weatherInfo.main.humidity)
            newItem.temperature = weatherInfo.main.temp
            newItem.weatherDescription = weatherInfo.weather.first?.description ?? ""
            newItem.windSpeed = weatherInfo.wind.speed
            newItem.city = city

            DispatchQueue.main.async {
                do {
                    try self.moc.save()
                } catch {
                    print(error)
                    // TODO: Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }

            print("Done")
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
    }
}

struct WeatherFormatter {
    private static let formatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    private static func kelvinToCelsius(kelvin: Float) -> Float {
        return kelvin - 273.15
    }

    static func formatTemperature(_ temperature: Float) -> String {
        let temperature = kelvinToCelsius(kelvin: temperature)
        if let formattedTemperature = formatter.string(from: NSNumber(value: temperature)) {
            return formattedTemperature + "° C"
        } else {
            return "\(temperature)° C"
        }
    }
}
