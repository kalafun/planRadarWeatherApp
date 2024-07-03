//
//  HistoricalInfoView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import CoreData
import SwiftUI

struct HistoricalInfoView: View {

    @EnvironmentObject var styler: Styler
    @ObservedObject var viewModel: HistoricalInfoView.ViewModel

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.weatherInfos) { item in
                    VStack(alignment: .leading) {
                        if let requestDate = item.requestDate {
                            Text(requestDate.formatted(date: .numeric, time: .shortened))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(styler.titleColor)
                        }
                        if let weatherDescription = item.weatherDescription {
                            Text(weatherDescription.capitalized + ", \(WeatherFormatter.formatTemperature(item.temperature))")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(styler.subtitleColor)
                        }
                    }
                    .listRowBackground(styler.backgroundColor)
                    .listRowSeparatorTint(styler.buttonColor)
                }
            }
            .listStyle(.plain)
        }
        .background(styler.backgroundColor)
        .onAppear {
            viewModel.fetchWeatherInfo()
        }
        .showViewModelError(isPresented: $viewModel.showsError, message: viewModel.errorText)
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
    .environmentObject(Styler.shared)
    .onAppear {
        Styler.shared.colorScheme = .dark
    }
}
