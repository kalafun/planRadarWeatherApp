//
//  ContentView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationStack {
            CitiesView()
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
            .navigationTitle("adadasds")
    }
}
