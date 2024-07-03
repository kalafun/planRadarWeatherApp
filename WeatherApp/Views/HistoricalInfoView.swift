//
//  HistoricalInfoView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import CoreData
import SwiftUI

struct HistoricalInfoView: View {

//    let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
//    fetchRequest.predicate = NSPredicate(format: "name == %@", city.name ?? "")

    private var fetchRequest: FetchRequest<WeatherInfo>
    private var items: FetchedResults<WeatherInfo> { fetchRequest.wrappedValue }
    private let city: City

    init(city: City) {
        self.city = city

        var predicate: NSPredicate?
        if let cityName = city.name {
            predicate = NSPredicate(format: "city.name == %@", cityName)
        }

        self.fetchRequest = FetchRequest<WeatherInfo>(
            entity: WeatherInfo.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \WeatherInfo.requestDate, ascending: true)],
            predicate: predicate,
            animation: .default
        )
    }

    var body: some View {
        VStack {
            List {
                ForEach(items) { item in
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
        .navigationTitle((city.name?.uppercased() ?? "") + " HISTORICAL")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let context = PersistenceController.weatherDetailPreview.container.viewContext
    let city = City(context: context)
    city.name = "Vienna"

    return NavigationStack {
        HistoricalInfoView(city: city)
    }
}
