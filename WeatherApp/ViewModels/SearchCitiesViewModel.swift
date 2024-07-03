//
//  SearchCitiesViewModel.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import SwiftUI
import CoreData

extension SearchCitiesView {

    @MainActor
    class ViewModel: AppViewModel {

        struct Item {
            let name: String
        }

        @Published var query = ""
        @Published var items = [Item]()
        private let weatherService: WeatherServiceProtocol
        private let moc: NSManagedObjectContext

        init(moc: NSManagedObjectContext, weatherService: WeatherServiceProtocol = WeatherService()) {
            self.moc = moc
            self.weatherService = weatherService
        }

        func searchCities(name: String) async {
            isLoading = true
            do {
                let response = try await weatherService.searchCity(name: name)
                items = response.list.compactMap { cityDTO in
                    Item(name: cityDTO.name + ", " + cityDTO.sys.country)
                }
            } catch {
                print(error)
                handleError(error: error)
            }
            isLoading = false
        }

        func add(cityItem: Item) {
            let newItem = City(context: moc)
            newItem.createdAt = Date()
            newItem.name = cityItem.name

            do {
                try moc.save()
            } catch {
                print(error)
                handleError(error: error)
            }
        }
    }
}

