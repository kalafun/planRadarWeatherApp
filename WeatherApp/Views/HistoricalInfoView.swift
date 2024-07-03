//
//  HistoricalInfoView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import CoreData
import SwiftUI

struct HistoricalInfoView: View {

    @ObservedObject var viewModel: HistoricalInfoView.ViewModel

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.weatherInfos) { item in
                    VStack(alignment: .leading) {
                        if let requestDate = item.requestDate {
                            Text(requestDate.formatted(date: .numeric, time: .shortened))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Styler.Color.title)
                        }
                        if let weatherDescription = item.weatherDescription {
                            Text(weatherDescription.capitalized + ", \(WeatherFormatter.formatTemperature(item.temperature))")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(Styler.Color.subtitle)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            viewModel.fetchWeatherInfo()
        }
        .navigationTitle((viewModel.city.name?.uppercased() ?? "") + " HISTORICAL")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let context = PersistenceController.weatherDetailPreview.container.viewContext
    let city = City(context: context)
    city.name = "Vienna"

    return NavigationStack {
        HistoricalInfoView(viewModel: HistoricalInfoView.ViewModel(city: city, moc: context))
    }
}

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
