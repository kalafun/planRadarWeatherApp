//
//  SearchCitiesView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI
import CoreData

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

extension SearchCitiesView {

    @MainActor
    class ViewModel: AppViewModel {

        struct Item {
            let name: String
        }

        @Published var query = ""
        @Published var items = [Item]()
        private let weatherService: WeatherServiceProtocol
        private let moc: NSManagedObjectContext

        init(moc: NSManagedObjectContext, weatherService: WeatherServiceProtocol = WeatherService()) {
            self.moc = moc
            self.weatherService = weatherService
        }

        func searchCities(name: String) async {
            isLoading = true
            do {
                let response = try await weatherService.searchCity(name: name)
                items = response.list.compactMap { cityDTO in
                    Item(name: cityDTO.name + ", " + cityDTO.sys.country)
                }
            } catch {
                print(error)
                // TODO: error handling
            }
            isLoading = false
        }

        func add(cityItem: Item) {
            let newItem = City(context: moc)
            newItem.createdAt = Date()
            newItem.name = cityItem.name
            
            do {
                try moc.save()
            } catch {
                // TODO: Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

@MainActor
class AppViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showsError = false
    var errorText = ""
}
