//
//  URLSession+.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/5/26.
//

import Foundation

extension URLSession {

    func data(for urlRequest: URLRequest) async throws -> Data {
        let (data, response) = try await self.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else { throw NetworkError.invalidURL}
        guard 200...299 ~= response.statusCode else { throw NetworkError.invalidCode(response.statusCode)}
        return data
    }
}
