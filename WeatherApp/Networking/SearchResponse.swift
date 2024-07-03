//
//  SearchResponse.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import Foundation

struct SearchResponse: Decodable {
    let list: [CityDTO]
}
