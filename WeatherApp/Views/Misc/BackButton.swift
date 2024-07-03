//
//  BackButton.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 03.07.24.
//

import SwiftUI

struct BackButton: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            ZStack {
                Image("Button_left")
                    .resizable()
                    .frame(height: 90)
                    .offset(x: -20, y: 18)
                Image(systemName: "arrow.left")
                    .foregroundStyle(Styler.Color.button)
                    .offset(x: -30, y: 0)
            }
        }
    }
}

#Preview("Back Button") {
    BackButton()
}
