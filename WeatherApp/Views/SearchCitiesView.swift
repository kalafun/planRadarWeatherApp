//
//  SearchCitiesView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

struct SearchCitiesView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var styler: Styler
    @EnvironmentObject var citiesViewModel: CitiesView.ViewModel

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.items.indices, id: \.self) { index in
                    let item = viewModel.items[index]
                    Text(item.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(styler.titleColor)
                        .onTapGesture {
                            viewModel.add(cityItem: item)
                            citiesViewModel.fetchCities()
                            dismiss()
                        }
                }
            }
            .searchable(text: $viewModel.query)
            .onChange(of: viewModel.query) { oldValue, newValue in
                if newValue.isEmpty {
                    viewModel.items = []
                    return
                }

                if newValue.count < 3 {
                    return
                }

                Task {
                    await viewModel.searchCities(name: newValue)
                }
            }
        }
        .onDisappear {
            viewModel.query = ""
        }
        .background(styler.backgroundColor)
        .showViewModelError(isPresented: $viewModel.showsError, message: viewModel.errorText)
        .overlay {
            if viewModel.isLoading {
                LoadingIndicator()
            }
        }
        .navigationTitle("Enter city, postcode or airoport location")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SearchCitiesView(viewModel: SearchCitiesView.ViewModel(moc: PersistenceController.shared.container.viewContext))
    }
    .environmentObject(Styler.shared)
    .onAppear {
        Styler.shared.colorScheme = .dark
    }
}
