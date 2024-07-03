//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

struct WeatherDetailView: View {

    @EnvironmentObject var styler: Styler
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            styler.backgroundColor
                .ignoresSafeArea()

            VStack {
                Spacer()
                Image("Background")
                    .resizable()
                    .frame(height: 375)
            }
            .ignoresSafeArea()

            VStack {
                VStack {
                    AsyncImage(url: viewModel.weatherIconURL) { image in
                        image
                            .resizable()
                            .frame(width: 120, height: 120)
                    } placeholder: {
                        ProgressView()
                    }
                    .padding(.bottom, 50)

                    VStack(spacing: 7) {
                        infoRow("description", right: viewModel.weatherDescription)
                        infoRow("temperature", right: viewModel.temperature)
                        infoRow("humidity", right: viewModel.humidity)
                        infoRow("windspeed", right: viewModel.windSpeed)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 55)
                .padding(.bottom, 45)
                .background(styler.detailBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: .black.opacity(0.2), radius: 30, y: 20)
                .padding(.horizontal, 50)
                .padding(.top, 45)

                Spacer()

                footer
            }
        }
        .onAppear {
            Task {
                await viewModel.getWeatherInfo()
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingIndicator()
            }
        }
        .showViewModelError(isPresented: $viewModel.showsError, message: viewModel.errorText)
        .navigationTitle(viewModel.cityName)
        .navigationBarTitleTextColor(styler.titleColor)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton()) // Use the custom back button
    }

    private func infoRow(_ left: String, right: String) -> some View {
        HStack {
            Text(left)
                .textCase(.uppercase)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(styler.titleColor)
            Spacer()
            Text(right)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(styler.subtitleColor)
        }
    }

    private var footer: some View {
        VStack {
            Text(viewModel.footerText)
                .multilineTextAlignment(.center)
                .font(.system(size: 12, weight: .regular))
            Text(viewModel.timeUpdatedString)
                .font(.system(size: 12, weight: .regular))
        }
        .foregroundStyle(styler.footerColor)
    }
}

#Preview {
    let context = PersistenceController.weatherDetailPreview.container.viewContext
    let city = City(context: context)
    city.name = "Vienna"

    return NavigationStack {
        WeatherDetailView(
            viewModel: WeatherDetailView.ViewModel(
                moc: context,
                city: city
            )
        )
        .environmentObject(Styler.shared)
    }
    .onAppear {
        Styler.shared.colorScheme = .dark
    }
}
