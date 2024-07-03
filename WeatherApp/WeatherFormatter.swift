//
//  WeatherFormatter.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import Foundation

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
