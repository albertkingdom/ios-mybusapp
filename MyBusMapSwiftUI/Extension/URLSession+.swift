//
//  URLSession+.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/5/26.
//

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
