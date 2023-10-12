//
//  APIService.swift
//  Project
//
//  Created by rayeon lee on 2023/04/02.
//

import Foundation
import RxSwift

// MARK: - Protocol

public enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

public protocol NetworkService {
    func request(endpoint: Requestable) -> Observable<Data>
    func request(with url: URL) -> Observable<Data>
}


public protocol NetworkSessionManager {
    func request(_ request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)>
}

// MARK: - Implementation

public final class DefaultNetworkService {
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    
    public init(config: NetworkConfigurable,
                sessionManager: NetworkSessionManager = DefaultNetworkSessionManager()) {
        self.sessionManager = sessionManager
        self.config = config
    }
    
    private func request(request: URLRequest) -> Observable<Data> {
        return sessionManager.request(request)
            .map({ result in
                if 200 ..< 300 ~= result.response.statusCode {
                    return result.data
                }
                else {
                    throw NetworkError.error(statusCode: result.response.statusCode, data: result.data)
                }
            })
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
            case .notConnectedToInternet: return .notConnected
            case .cancelled: return .cancelled
            default: return .generic(error)
        }
    }
}

extension DefaultNetworkService: NetworkService {
    public func request(endpoint: Requestable) -> Observable<Data> {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest)
        } catch {
            return Observable.error(NetworkError.urlGeneration)
        }
    }
    
    public func request(with url: URL) -> Observable<Data> {
        return request(request: URLRequest(url: url))
        
    }
}


public class DefaultNetworkSessionManager: NetworkSessionManager {
    public init() {}
    public func request(_ request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)> {
        return URLSession.shared.rx.response(request: request)
    }
    
}
