//
//  CitiesViewModel.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import CoreData
import SwiftUI

extension CitiesView {

    @MainActor
    class ViewModel: AppViewModel {

        @Published var cities = [City]()

        @Published var showsSearchCitiesView = false
        @Published var historicalCity: City?
        @Published var weatherDetailCity: City?
        @Published var weatherDetailViewModel: WeatherDetailView.ViewModel?
        @Published var searchCitiesViewModel: SearchCitiesView.ViewModel

        let moc: NSManagedObjectContext

        init(moc: NSManagedObjectContext) {
            self.moc = moc

            searchCitiesViewModel = SearchCitiesView.ViewModel(moc: moc)
        }

        func fetchCities() {
            let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \City.createdAt, ascending: true)]

            do {
                cities = try moc.fetch(fetchRequest)
            } catch {
                print("Failed to fetch weather info: \(error)")
                handleError(error: error)
            }
        }
    }
}
