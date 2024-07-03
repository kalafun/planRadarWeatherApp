//
//  CitiesView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import CoreData
import SwiftUI

struct CitiesView: View {

    @StateObject var viewModel = CitiesView.ViewModel()

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \City.createdAt, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<City>

    var body: some View {
        List {
            ForEach(items) { item in
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
                        viewModel.weatherDetailViewModel = WeatherDetailView.ViewModel(moc: viewContext, city: item)
                        viewModel.weatherDetailCity = item
                    }

                    Button {
                        viewModel.historicalCity = item
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Styler.Color.subtitle)
                    }
                }
                //                        Text(item.timestamp!, formatter: itemFormatter)
            }
            //            .onDelete(perform: deleteItems)
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
                SearchCitiesView(viewModel: SearchCitiesView.ViewModel(moc: viewContext))
            }
        }
        .sheet(item: $viewModel.historicalCity) { historicalCity in
            NavigationStack {
                HistoricalInfoView(viewModel: HistoricalInfoView.ViewModel(city: historicalCity, moc: viewContext))
            }
        }
    }
}

#Preview {
    NavigationStack {
        CitiesView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension CitiesView {

    @MainActor
    class ViewModel: AppViewModel {
        @Published var showsSearchCitiesView = false
        @Published var historicalCity: City?
        @Published var weatherDetailCity: City?
        @Published var weatherDetailViewModel: WeatherDetailView.ViewModel?
    }
}
