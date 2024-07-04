//
//  WeatherDetailViewModel.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import SwiftUI
import CoreData

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
            weatherService: WeatherServiceProtocol = WeatherService()
        ) {
            self.moc = moc
            self.city = city
            self.weatherService = weatherService
        }

        func getWeatherInfo() async {
            isLoading = true
            do {
                let response = try await weatherService.getWeatherInfo(city: cityName)
                let timeUpdated = Date()
                self.weatherInfoResponse = response
                self.timeUpdated = timeUpdated
                self.footerText = "weather information for \(cityName) received on".uppercased()
                saveWeatherInfo(for: city, weatherInfo: weatherInfoResponse!, tiemUpdated: timeUpdated)
                self.isLoading = false
            } catch {
                print(error)
                handleError(error: error)
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

            do {
                try self.moc.save()
            } catch {
                print(error)
                handleError(error: error)
            }
        }
    }
}

