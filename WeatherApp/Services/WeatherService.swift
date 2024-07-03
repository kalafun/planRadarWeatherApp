//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import Foundation

class Service {
    let baseURL = URL(string: "https://api.openweathermap.org/")!
}

protocol WeatherServiceProtocol {
    func searchCity(name: String) async throws -> SearchResponse
    func getWeatherInfo(city: String) async throws -> WeatherInfoResponse
}

class WeatherService: Service, WeatherServiceProtocol {
    
    // api.openweathermap.org/data/2.5/find?q=Vienna&appId=f5cb0b965ea1564c50c6f1b74534d823
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

struct WeatherInfoResponse: Decodable {
    struct Weather: Decodable {
        let description: String
        let icon: String
    }

    struct Main: Decodable {
        let temp: Float
        let humidity: Int
    }

    struct Wind: Decodable {
        let speed: Float
    }

    let weather: [Weather]
    let main: Main
    let wind: Wind
}

struct SearchResponse: Decodable {
    let list: [CityDTO]
}

struct CityDTO: Decodable {
    struct Sys: Decodable {
        let country: String
    }
    let name: String
    let sys: Sys
}
