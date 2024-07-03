//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

struct WeatherDetailView: View {

    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
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
                .background()
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: .black.opacity(0.1), radius: 10)
                .padding(.horizontal, 50)
                .padding(.top, 45)

                Spacer()

                footer
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton()) // Use the custom back button
        .onAppear {
            Task {
                await viewModel.getWeatherInfo()
            }
        }
    }

    private func infoRow(_ left: String, right: String) -> some View {
        HStack {
            Text(left)
                .textCase(.uppercase)
                .font(.system(size: 12, weight: .bold))
            Spacer()
            Text(right)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Styler.Color.subtitle)
        }
    }

    private var footer: some View {
        VStack {
            Text(viewModel.footerText)
                .multilineTextAlignment(.center)
                .font(.system(size: 12, weight: .regular))
            if let timeUpdatedString = viewModel.timeUpdatedString {
                Text(timeUpdatedString)
                    .font(.system(size: 12, weight: .regular))
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeatherDetailView(viewModel: WeatherDetailView.ViewModel(cityName: "Vienna"))
    }
}

extension WeatherDetailView {

    @MainActor
    class ViewModel: AppViewModel {

        let cityName: String

        @Published var weatherInformation: WeatherInfoResponse?
        @Published var footerText: String = ""
        var timeUpdated: Date? {
            didSet {
                timeUpdatedString = timeUpdated?.formatted(date: .abbreviated, time: .shortened)
            }
        }
        @Published var timeUpdatedString: String?

        var weatherIconURL: URL? {
            guard let weatherInformation = weatherInformation,
                  let icon = weatherInformation.weather.first?.icon else { return nil }
            return URL(string: "https://openweathermap.org/img/wn/\(icon)@4x.png")
        }
        var weatherDescription: String { weatherInformation?.weather.first?.description.capitalized ?? "" }
        var temperature: String { weatherInformation?.main.temp.description ?? "" }
        var humidity: String { "\(weatherInformation?.main.humidity ?? 0)%"}
        var windSpeed: String { "\(weatherInformation?.wind.speed ?? 0)" + "km/h" }

        private let weatherService: WeatherServiceProtocol

        init(cityName: String, weatherServoce: WeatherServiceProtocol = WeatherService()) {
            self.cityName = cityName
            self.weatherService = weatherServoce
        }

        func getWeatherInfo() async {

            isLoading = true
            do {
                weatherInformation = try await weatherService.getWeatherInfo(city: cityName)
                timeUpdated = Date()
                footerText = "weather information for \(cityName) received on".uppercased()
                // TODO: get weather icon
            } catch {
                print(error)
                // TODO: Error handling
            }
            isLoading = false
        }
    }
}

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
