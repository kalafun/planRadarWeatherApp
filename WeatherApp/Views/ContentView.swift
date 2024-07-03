//
//  ContentView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

struct ContentView: View {

    @StateObject var citiesViewModel = CitiesView.ViewModel(moc: PersistenceController.shared.container.viewContext)

    var body: some View {
        NavigationStack {
            CitiesView(viewModel: citiesViewModel)
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
            .navigationTitle("adadasds")
    }
}
