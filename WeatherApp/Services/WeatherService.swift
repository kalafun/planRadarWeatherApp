//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import Foundation

protocol WeatherServiceProtocol {
    func searchCity(name: String) async throws -> SearchResponse
    func getWeatherInfo(city: String) async throws -> WeatherInfoResponse
}

class WeatherService: Service, WeatherServiceProtocol {

    /// Search for a city by name. returns `SearchResponse`
    /// - Parameter name: Name of the city to search for
    /// - Returns: SearchResponse with a list of cities
    func searchCity(name: String) async throws -> SearchResponse {
        let url = baseURL.appending(path: "data/2.5/find").appending(
            queryItems: [
                URLQueryItem(name: "appId", value: Config.weatherAPIKey),
                URLQueryItem(name: "q", value: name)
            ]
        )
        let request = URLRequest(url: url)
        return try await APIClient.shared.data(for: request)
    }

    /// Get weather information for city with name
    /// - Parameter city: City name to get weather information for
    /// - Returns: `WeatherResponse` with temperature, weather description, humidity, and other data
    func getWeatherInfo(city: String) async throws -> WeatherInfoResponse {
        let url = baseURL.appending(path: "data/2.5/weather").appending(
            queryItems: [
                URLQueryItem(name: "appId", value: Config.weatherAPIKey),
                URLQueryItem(name: "q", value: city)
            ]
        )
        let request = URLRequest(url: url)
        return try await APIClient.shared.data(for: request)
    }
}
