//
//  LoadingIndicator.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

struct LoadingIndicator: View {
    var body: some View {
        ProgressView()
            .padding(24)
            .background()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.2), radius: 10)
    }
}

#Preview {
    LoadingIndicator()
}
