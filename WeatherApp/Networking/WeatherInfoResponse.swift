//
//  WeatherInfoResponse.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import Foundation

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
