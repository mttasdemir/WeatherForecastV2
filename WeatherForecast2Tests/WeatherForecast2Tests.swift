//
//  WeatherForecast2Tests.swift
//  WeatherForecast2Tests
//
//  Created by Mustafa Taşdemir on 16.05.2022.
//

import XCTest
@testable import WeatherForecast2

class WeatherForecast2Tests: XCTestCase {

    func testCityDecode() {
        XCTAssertEqual(City.sampleData.name, "Istanbul")
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
