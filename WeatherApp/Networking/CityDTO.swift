//
//  CityDTO.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import Foundation

struct CityDTO: Decodable {
    struct Sys: Decodable {
        let country: String
    }
    let name: String
    let sys: Sys
}
