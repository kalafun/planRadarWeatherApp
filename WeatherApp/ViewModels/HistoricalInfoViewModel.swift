//
//  HistoricalInfoViewModel.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import SwiftUI
import CoreData

extension HistoricalInfoView {

    @MainActor
    class ViewModel: AppViewModel {
        @Published var weatherInfos = [WeatherInfo]()
        @Published var city: City

        var moc: NSManagedObjectContext

        init(city: City, moc: NSManagedObjectContext) {
            self.city = city
            self.moc = moc
        }

        func fetchWeatherInfo() {
            let fetchRequest: NSFetchRequest<WeatherInfo> = WeatherInfo.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WeatherInfo.requestDate, ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "city == %@", city)

            do {
                let result = try moc.fetch(fetchRequest)
                DispatchQueue.main.async {
                    self.weatherInfos = result
                }
            } catch {
                print("Failed to fetch weather info: \(error)")
            }
        }
    }
}
