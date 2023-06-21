//
//  NetworkManagerTests.swift
//  DiaryTests
//
//  Created by 리지 on 2023/06/21.
//

import XCTest
@testable import Diary

final class NetworkManagerTests: XCTestCase {
    var sut: NetworkManager!
    var expectation: XCTestExpectation!
    var iconExpectation: XCTestExpectation!
    var weatherEndpoint: WeatherEndpoint!
    var weatherIconEndpoint: WeatherEndpoint!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        
        sut = NetworkManager(urlSession: urlSession)
        weatherEndpoint = WeatherEndpoint.weatherInformation(latitude: "44.34", longitude: "10.99")
        weatherIconEndpoint = WeatherEndpoint.weatherIcon(icon: "10d")
        expectation = expectation(description: "weatherInformation")
        iconExpectation = expectation(description: "weatherIcon")
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        sut = nil
        weatherEndpoint = nil
        weatherIconEndpoint = nil
        expectation = nil
        iconExpectation = nil
    }
    
    func test_error가nil이아니면_unknown_error가발생한다() {
        // given
        guard let url: URL = weatherEndpoint.createURL(),
              let data = NSDataAsset(name: "weather sample")?.data else { return }
        
        MockURLProtocol.requestHandler = { _ in
            
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) 
            
            return (data, response, DiaryError.networkUnknown)
        }
        let expectationResult = DiaryError.networkUnknown.description
        
        // when
        sut.startLoad(endPoint: weatherEndpoint, returnType: WeatherInformation.self) { result in
            switch result {
            case .success(_):
                XCTFail("Success response was not expected.")
            case .failure(let error):
                XCTAssertEqual(error
                    .description, expectationResult)
            }
            self.expectation.fulfill()
        }
        
        sut.imageLoad(endPoint: weatherIconEndpoint) { result in
            switch result {
            case .success(_):
                XCTFail("Success response was not expected.")
            case .failure(let error):
                XCTAssertEqual(error
                    .description, expectationResult)
            }
            self.iconExpectation.fulfill()
        }
        // then
        wait(for: [expectation, iconExpectation], timeout: 1.0)
    }
    
    func test_response가_HTTPURLResponse타입이아니면_responseError가발생한다() {
        // given
        guard let url: URL = weatherEndpoint.createURL(),
              let data = NSDataAsset(name: "weather sample")?.data else { return }
        
        MockURLProtocol.requestHandler = { _ in
            
            let response = URLResponse(url: url, mimeType: "test", expectedContentLength: -1, textEncodingName: nil)
            
            return (data, response, nil)
        }
        let expectationResult = DiaryError.networkResponse.description
        
        // when
        sut.startLoad(endPoint: weatherEndpoint, returnType: WeatherInformation.self) { result in
            switch result {
            case .success(_):
                XCTFail("Success response was not expected.")
            case .failure(let error):
                XCTAssertEqual(error
                    .description, expectationResult)
            }
            self.expectation.fulfill()
        }
        
        sut.imageLoad(endPoint: weatherIconEndpoint) { result in
            switch result {
            case .success(_):
                XCTFail("Success response was not expected.")
            case .failure(let error):
                XCTAssertEqual(error
                    .description, expectationResult)
            }
            self.iconExpectation.fulfill()
        }
        // then
        wait(for: [expectation, iconExpectation], timeout: 1.0)
    }
    
    func test_httpResponse가200_299사이가아니라면_statusCodeError가발생한다() {
        // given
        guard let url: URL = weatherEndpoint.createURL(),
              let data = NSDataAsset(name: "weather sample")?.data else { return }
        
        MockURLProtocol.requestHandler = { _ in
            
            let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
            
            return (data, response, nil)
        }
        let expectationResult = DiaryError.networkStatusCode(code: 400).description
        
        // when
        sut.startLoad(endPoint: weatherEndpoint, returnType: WeatherInformation.self) { result in
            switch result {
            case .success(_):
                XCTFail("Success response was not expected.")
            case .failure(let error):
                XCTAssertEqual(error
                    .description, expectationResult)
            }
            self.expectation.fulfill()
        }
        
        sut.imageLoad(endPoint: weatherIconEndpoint) { result in
            switch result {
            case .success(_):
                XCTFail("Success response was not expected.")
            case .failure(let error):
                XCTAssertEqual(error
                    .description, expectationResult)
            }
            self.iconExpectation.fulfill()
        }
        
        // then
        wait(for: [expectation, iconExpectation], timeout: 1.0)
    }
    
    func test_data가nil이아니라면_case_success가실행된다() {
        // given
        guard let url: URL = weatherEndpoint.createURL(),
              let data = NSDataAsset(name: "weather sample")?.data else { return }
        
        MockURLProtocol.requestHandler = { _ in
            
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            
            return (data, response, nil)
        }
        let expectationResult = "10d"
        
        // when
        sut.startLoad(endPoint: weatherEndpoint, returnType: WeatherInformation.self) { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data.weather[0].icon, expectationResult)
            case .failure(_):
                XCTFail("Failure response was not expected.")
            }
            self.expectation.fulfill()
        }
        
        sut.imageLoad(endPoint: weatherIconEndpoint) { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure(_):
                XCTFail("Failure response was not expected.")
            }
            self.iconExpectation.fulfill()
        }
        
        // then
        wait(for: [expectation, iconExpectation], timeout: 1.0)
    }
    
}
