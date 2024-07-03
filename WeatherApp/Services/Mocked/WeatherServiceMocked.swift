//
//  WeatherServiceMocked.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import Foundation

class WeatherServiceMocked: Service, WeatherServiceProtocol {
    func searchCity(name: String) async throws -> SearchResponse {
        SearchResponse(
            list: [
                CityDTO(
                    name: "Vienna",
                    sys: CityDTO.Sys(country: "AT")
                )
            ]
        )
    }

    func getWeatherInfo(city: String) async throws -> WeatherInfoResponse {
        WeatherInfoResponse(
            weather: [
                WeatherInfoResponse.Weather(
                    description: "Cloudy",
                    icon: "01d"
                )
            ],
            main: WeatherInfoResponse.Main(
                temp: 324,
                humidity: 44
            ),
            wind: WeatherInfoResponse.Wind(speed: 32.4)
        )
    }
}
