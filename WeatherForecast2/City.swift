//
//  Forecast.swift
//  WeatherForecast2
//
//  Created by Mustafa Taşdemir on 15.05.2022.
//

import Foundation

struct City: Identifiable, Decodable {

    
    let id: UUID = UUID()
    var name: String
    let country: String
    let localTime: Date
    let geoPosition: GeoPosition
    var forecast: Forecast?
    
    enum CodingKeysCity: String, CodingKey {
        case location = "location", forecast = "current"
    }
    enum CodingKeysLocation: String, CodingKey {
        case name = "name", country = "country", localTime = "localtimeEpoch", latitude = "lat", longitude = "lon"
    }
    
    struct GeoPosition: Decodable {
        var latitude: Double = 0
        var longitude: Double = 0
    }
    
    struct Forecast: Decodable {
        let temperature: Int
        let weatherIcons: Array<String>
        let weatherDescriptions: Array<String>
        let windSpeed: Int
        let humidity: Int
        let pressure: Int
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysCity.self)
        let locationContainer = try container.nestedContainer(keyedBy: CodingKeysLocation.self, forKey: .location)
        self.name = try locationContainer.decode(String.self, forKey: .name)
        self.country = try locationContainer.decode(String.self, forKey: .country)
        self.localTime = try locationContainer.decode(Date.self, forKey: .localTime)
        var geoPosition = GeoPosition()
        geoPosition.latitude = Double(try locationContainer.decode(String.self, forKey: .latitude)) ?? 0
        geoPosition.longitude = Double(try locationContainer.decode(String.self, forKey: .longitude)) ?? 0
        self.geoPosition = geoPosition
        self.forecast = try container.decode(Forecast.self, forKey: .forecast)
    }
    
    init(name: String, country: String, localTime: Date) {
        self.name = name
        self.country = country
        self.localTime = localTime
        self.geoPosition = GeoPosition()
    }
}

extension City {
    static var defaultCity = City(name: "Ankara", country: "Turkey", localTime: Date.now)
    static var sampleData: City = City.loadCity("Istanbul")

    static func loadCity(_ city: String) -> City {
        guard let fileUrl = Bundle.main.url(forResource: city, withExtension: "json") else {
            return defaultCity
        }
        do {
            let fileHandle = try FileHandle(forReadingFrom: fileUrl)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .secondsSince1970
            let city = try decoder.decode(City.self, from: fileHandle.availableData)
            return city
        } catch {
            return defaultCity
        }
    }
    
}

