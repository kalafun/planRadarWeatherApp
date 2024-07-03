//
//  ContentView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

struct ContentView: View {

    @Environment(\.colorScheme) var colorScheme
    @StateObject private var styler = Styler.shared
    @StateObject var citiesViewModel = CitiesView.ViewModel(moc: PersistenceController.shared.container.viewContext)

    var body: some View {
        NavigationStack {
            CitiesView(viewModel: citiesViewModel)
        }
        .environmentObject(styler)
        .onChange(of: colorScheme) { oldValue, newValue in
            styler.colorScheme = newValue
        }
        .onAppear {
            styler.colorScheme = colorScheme
        }
    }
}

#Preview {
    ContentView()
}
