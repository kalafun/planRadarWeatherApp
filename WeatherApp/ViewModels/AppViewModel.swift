//
//  AppViewModel.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showsError = false
    var errorText = ""
}
