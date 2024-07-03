//
//  CitiesView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

struct CitiesView: View {

    @EnvironmentObject var styler: Styler
    @ObservedObject var viewModel: CitiesView.ViewModel

    var body: some View {
        List {
            ForEach(viewModel.cities) { item in
                HStack(spacing: 20) {
                    HStack() {
                        Text(item.name ?? "")
                            .foregroundStyle(styler.titleColor)
                            .font(.system(size: 17, weight: .bold))
                            .listRowSeparatorTint(styler.buttonColor)

                        Spacer()
                    }
                    .background(styler.backgroundColor)
                    .onTapGesture {
                        viewModel.weatherDetailViewModel = WeatherDetailView.ViewModel(moc: viewModel.moc, city: item)
                        viewModel.weatherDetailCity = item
                    }

                    Button {
                        viewModel.historicalCity = item
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(styler.subtitleColor)
                    }
                }
                .listRowBackground(styler.backgroundColor)
            }
        }
        .onAppear {
            viewModel.fetchCities()
        }
        .showViewModelError(isPresented: $viewModel.showsError, message: viewModel.errorText)
        .padding(.top, 38)
        .listStyle(.plain)
        .navigationTitle("CITIES")
        .navigationBarTitleTextColor(styler.titleColor)
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
                    .tint(styler.buttonColor)
                }
            }
        }
        .background(styler.backgroundColor)
        .navigationDestination(item: $viewModel.weatherDetailCity) { city in
            if let weatherDetailViewModel = viewModel.weatherDetailViewModel {
                WeatherDetailView(viewModel: weatherDetailViewModel)
            }
        }
        .sheet(isPresented: $viewModel.showsSearchCitiesView) {
            NavigationStack {
                SearchCitiesView(viewModel: viewModel.searchCitiesViewModel)
                    .environmentObject(viewModel)
            }
            .tint(styler.subtitleColor)
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
    .environmentObject(Styler.shared)
    .onAppear {
        Styler.shared.colorScheme = .dark
    }
}
