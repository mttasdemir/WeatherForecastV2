//
//  WeatherForecast2App.swift
//  WeatherForecast2
//
//  Created by Mustafa Taşdemir on 11.05.2022.
//

import SwiftUI

@main
struct WeatherForecast2App: App {
    @StateObject private var controller = ForecastController()
    var body: some Scene {
        WindowGroup {
            ForecastView(forecastController: controller)
        }
    }
}
