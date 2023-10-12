//
//  NetworkSessionManagerMock.swift
//  ExampleMVVMTests
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import RxSwift

@testable import Project

struct NetworkSessionManagerMock: NetworkSessionManager {
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
    
    func request(_ request: URLRequest) -> Observable<Data> {
        return Observable.just(data!)
    }
}
