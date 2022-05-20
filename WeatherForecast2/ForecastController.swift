//
//  ForecastController.swift
//  WeatherForecast2
//
//  Created by Mustafa Taşdemir on 16.05.2022.
//

import Foundation

class ForecastController: ObservableObject {
    //http://api.weatherstack.com/current?access_key=f3b3cb12d326f2f5bfb3be1b35169831&query=Istanbul
    static private let accessKey = "f3b3cb12d326f2f5bfb3be1b35169831"
    static private let baseUrl = "http://api.weatherstack.com/current"
    
    @Published var cities: Array<City> = []
    var error: ForecastError?
    
    let citySet = ["İstanbul" : "Istanbul", "İzmir" : "Izmir", "Ankara" : "Ankara", "Kayseri" : "Kayseri", "Çanakkale" : "Canakkale", "Aydın" : "Aydin", "Adana" : "Adana", "Muğla" : "Mugla", "Antalya" : "Antalya", "Washington" : "Washington", "New York" : "New%20York"]
    
    var allCities: Array<String> {
        citySet.keys.filter { cityName in
            !cities.contains { $0.name == cityName }
        }.sorted(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
    }
    
    // MARK: - Intensions
    
    func addCityV1(_ name: String) {
        cities.append(City.loadCity(name))
    }
    
    func addCity(_ name: String) async throws {
        let url = ForecastController.baseUrl + "?access_key=\(ForecastController.accessKey)&query=\(citySet[name]!)"
        guard let url = URL(string: url) else {
            throw ForecastError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ForecastError.invalidServerResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        var city = try decoder.decode(City.self, from: data)
        city.name = name
        try await save(name)
        DispatchQueue.main.async { [city] in
            self.cities.append(city)
        }
    }
    
    func refreshForecast() async {
        let temp = cities
        cities.removeAll()
        for city in temp {
            try? await addCity(city.name)
        }
    }
    
    func remove(_ city: City) {
        if let index = cities.firstIndex(where: { $0.id == city.id }) {
            cities.remove(at: index)
        }
    }
    
    func save(_ name: String) async throws {
        // xcrun simctl get_app_container booted tr.tasdemir.app.test.WeatherForecast2 data
        var cityList = cities.map { $0.name }
        cityList.append(name)
        let direcUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileUrl = direcUrl?.appendingPathComponent("Cities.json")
        let jsonData = try JSONEncoder().encode(cityList)
        try jsonData.write(to: fileUrl!)
    }
    
    func load() async {
        guard let fileUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("Cities.json") else { return }
        
        guard let jsonData = try? FileHandle(forReadingFrom: fileUrl).availableData else { return }
        guard let nameList = try? JSONDecoder().decode(Array<String>.self, from: jsonData) else { return }
        for name in nameList {
            try? await addCity(name)
        }
    }
    
}

enum ForecastError: Error {
    case invalidUrl, invalidServerResponse
}

