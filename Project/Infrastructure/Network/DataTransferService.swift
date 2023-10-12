//
//  DataTransferService.swift
//  Project
//
//  Created by rayeon lee on 2023/04/07.
//

import Foundation
import RxSwift

public enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

// MARK: - Protocol
public protocol DataTransferService {
    //ResponseRequestable을 얻는 request
    @discardableResult
    func request<T, E>(with endpoint: E) -> Observable<T> where T : Decodable, T == E.Response, E : ResponseRequestable
    
    //data을 얻는 request
    func request(with url: URL) -> Observable<Data>
    
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

// MARK: - Implementation
public final class DefaultDataTransferService {
    private let networkService: NetworkService

    public init(with networkService: NetworkService) {
        self.networkService = networkService
    }
}

extension DefaultDataTransferService: DataTransferService {
    public func request<T, E>(with endpoint: E) -> Observable<T> where T : Decodable, T == E.Response, E : ResponseRequestable {
        return self.networkService.request(endpoint: endpoint)
            .map { data in
                do {
                    let result: T = try endpoint.responseDecoder.decode(data)
                    return result
                } catch {
                    throw DataTransferError.parsing(error)
                }
            }
           
    }

    public func request(with url: URL) -> Observable<Data> {
        return self.networkService.request(with: url)
    }

}

// MARK: - Response Decoders
public class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    public init() { }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

public class RawDataResponseDecoder: ResponseDecoder {
    public init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(codingPath: [CodingKeys.default], debugDescription: "Expected Data type")
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
