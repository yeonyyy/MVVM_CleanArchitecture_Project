//
//  NetworkServiceTests.swift
//  ProjectTests
//
//  Created by rayeon lee on 2023/09/12.
//

import XCTest

@testable import Project

final class NetworkServiceTests: XCTestCase {
    
    private struct EndpointMock: Requestable {
        var path: String
        var isFullPath: Bool = false
        var method: HTTPMethodType
        var headerParameters: [String: String] = [:]
        var queryParametersEncodable: Encodable?
        var queryParameters: [String: Any] = [:]
        var bodyParametersEncodable: Encodable?
        var bodyParameters: [String: Any] = [:]
        var bodyEncoding: BodyEncoding = .stringEncodingAscii
        
        init(path: String, method: HTTPMethodType) {
            self.path = path
            self.method = method
        }
    }
    
    private enum NetworkErrorMock: Error {
        case someError
    }
    
    func test_whenMockDataPassed_shouldReturnProperResponse() throws {
        //given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should return correct data")
        
        let expectedResponseData = "Response data".data(using: .utf8)!
        let sut = DefaultNetworkService(config: config,
                                        sessionManager: NetworkSessionManagerMock(response: nil,
                                                                                  data: expectedResponseData,
                                                                                  error: nil))
        //when
        _ = sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get))
            .map{ responseData in
                print(responseData)
                XCTAssertEqual(responseData, expectedResponseData)
                expectation.fulfill()
            }

        //then
        wait(for: [expectation], timeout: 1)
        
        
    }
    
}
