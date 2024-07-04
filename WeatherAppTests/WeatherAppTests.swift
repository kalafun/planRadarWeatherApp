//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Tomas Bobko on 03.07.24.
//

@testable import WeatherApp
import CoreData
import XCTest

final class WeatherAppTests: XCTestCase {

    var context: NSManagedObjectContext!
    var weatherService: WeatherServiceMocked!

    override func setUpWithError() throws {
        context = PersistenceController.shared.container.viewContext
        weatherService = WeatherServiceMocked()
    }

    override func tearDownWithError() throws {
        weatherService = nil
        try super.tearDownWithError()
    }

    func testSearchCities() async throws {
        let searchViewModel = await SearchCitiesView.ViewModel(moc: context, weatherService: weatherService)

        await searchViewModel.searchCities(name: "Vienna")

        let viennaCity = await searchViewModel.items.first(where: { $0.name.contains("Vienna") })
        XCTAssertNotNil(viennaCity, "City 'Vienna' not found")
    }

    @MainActor
    func testGetWeatherInformation() async throws {
        let city = City(context: context)
        city.name = "Vienna, AT"
        let weatherInfoViewModel = WeatherDetailView.ViewModel(
            moc: context,
            city: city,
            weatherService: weatherService
        )

        await weatherInfoViewModel.getWeatherInfo()
        guard let response = weatherInfoViewModel.weatherInfoResponse else {
            XCTFail("No weather response")
            return
        }

        XCTAssert(response.wind.speed == 32.4)
    }
}
