//
//  SearchCitiesView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

struct SearchCitiesView: View {

    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.items.indices, id: \.self) { index in
                    let item = viewModel.items[index]
                    Text(item.name)
                        .onTapGesture {
                            viewModel.add(cityItem: item)
                            dismiss()
                        }
                }
            }
            .searchable(text: $viewModel.query)
            .onChange(of: viewModel.query) { oldValue, newValue in
                if newValue.isEmpty {
                    viewModel.items = []
                }
                Task {
                    await viewModel.searchCities(name: newValue)
                }
            }
        }
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
}
