//
//  Styler.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

class Styler: ObservableObject {

    static let shared = Styler()

    @Published var colorScheme: ColorScheme = .light {
        didSet {
            updateColors()
        }
    }

    @Published var buttonColor = Color.black
    @Published var titleColor = Color.black
    @Published var subtitleColor = Color.black
    @Published var backgroundColor = Color.black
    @Published var detailBackgroundColor = Color.black
    @Published var footerColor = Color.black

    func updateColors() {
        buttonColor = colorScheme == .dark ? Color(hex: "252526") : Color(hex: "252526")
        titleColor = colorScheme == .dark ? Color(hex: "797F88") : Color(hex: "797F88")
        subtitleColor = colorScheme == .dark ? Color(hex: "C53249") : Color(hex: "C53249")
        backgroundColor = colorScheme == .dark ? Color(hex: "262627") : Color(UIColor.systemBackground)
        detailBackgroundColor = colorScheme == .dark ? Color(hex: "2E2E2E") : Color(UIColor.systemBackground)
        footerColor = colorScheme == .dark ? Color(hex: "3D4548") : Color(hex: "3D4548")
    }
}
