//
//  CitiesView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import CoreData
import SwiftUI

struct CitiesView: View {

    @ObservedObject var viewModel: CitiesView.ViewModel

    var body: some View {
        List {
            ForEach(viewModel.cities) { item in
                HStack(spacing: 20) {
                    HStack() {
                        Text(item.name ?? "")
                            .foregroundStyle(Styler.Color.title)
                            .font(.system(size: 17, weight: .bold))
                            .listRowSeparatorTint(Styler.Color.button)

                        Spacer()
                    }
                    .background()
                    .onTapGesture {
                        viewModel.weatherDetailViewModel = WeatherDetailView.ViewModel(moc: viewModel.moc, city: item)
                        viewModel.weatherDetailCity = item
                    }

                    Button {
                        viewModel.historicalCity = item
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Styler.Color.subtitle)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchWeatherInfo()
        }
        .padding(.top, 38)
        .listStyle(.plain)
        .navigationTitle("CITIES")
        .navigationBarTitleTextColor(Styler.Color.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                ZStack {
                    HStack(spacing: 0) {
                        Spacer()
                        VStack(spacing: 0) {
                            Image("Button_right")
                                .offset(x: 16, y: 24)
                            Spacer()
                        }
                    }

                    Button {
                        viewModel.showsSearchCitiesView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .offset(x: 24)
                    .tint(Styler.Color.button)
                }
            }
        }
        .navigationDestination(item: $viewModel.weatherDetailCity) { city in
            if let weatherDetailViewModel = viewModel.weatherDetailViewModel {
                WeatherDetailView(viewModel: weatherDetailViewModel)
            }
        }
        .sheet(isPresented: $viewModel.showsSearchCitiesView) {
            NavigationStack {
                SearchCitiesView(viewModel: SearchCitiesView.ViewModel(moc: viewModel.moc))
            }
        }
        .sheet(item: $viewModel.historicalCity) { historicalCity in
            NavigationStack {
                HistoricalInfoView(viewModel: HistoricalInfoView.ViewModel(city: historicalCity, moc: viewModel.moc))
            }
        }
    }
}

#Preview {
    NavigationStack {
        CitiesView(viewModel: CitiesView.ViewModel(moc: PersistenceController.preview.container.viewContext))
    }
}

extension CitiesView {

    @MainActor
    class ViewModel: AppViewModel {

        @Published var cities = [City]()

        @Published var showsSearchCitiesView = false
        @Published var historicalCity: City?
        @Published var weatherDetailCity: City?
        @Published var weatherDetailViewModel: WeatherDetailView.ViewModel?

        let moc: NSManagedObjectContext

        init(moc: NSManagedObjectContext) {
            self.moc = moc
        }

        func fetchWeatherInfo() {
            let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \City.createdAt, ascending: true)]

            do {
                let result = try moc.fetch(fetchRequest)
                DispatchQueue.main.async {
                    self.cities = result
                }
            } catch {
                print("Failed to fetch weather info: \(error)")
            }
        }
    }
}
