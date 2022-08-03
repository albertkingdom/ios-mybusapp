//
//  NetworkManager.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import Foundation
import SwiftUI

class NetworkManager {
    static let shared = NetworkManager()
//    var token = ""
    func fetchToken() {
        let clientID = "albertkingdom.develop-f4ad6104-d27d-46a4"
        let clientKey = "f26624ff-5940-4e77-a38e-f17e042e1767"
        guard let url = URL(string: "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "post"
        request.setValue("application/x-www-form-urlencoded",                                 forHTTPHeaderField: "Content-Type")
        let parameters = "grant_type=client_credentials&client_id=\(clientID)&client_secret=\(clientKey)"
        let postData =  parameters.data(using: .utf8)
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("error \(error)")
            }
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let token = try decoder.decode(Token.self, from: data)
//                    self.token = token.accessToken
                } catch {
                    print("error \(error)")
                }
            }
        }.resume()
    }
    func fetchToken() async throws -> Token {
        let clientID = "albertkingdom.develop-f4ad6104-d27d-46a4"
        let clientKey = "f26624ff-5940-4e77-a38e-f17e042e1767"
        guard let url = URL(string: "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token") else {
            throw NetworkError.invalidURL
            
        }
        var request = URLRequest(url: url)
        request.httpMethod = "post"
        request.setValue("application/x-www-form-urlencoded",                                 forHTTPHeaderField: "Content-Type")
        let parameters = "grant_type=client_credentials&client_id=\(clientID)&client_secret=\(clientKey)"
        let postData =  parameters.data(using: .utf8)
        request.httpBody = postData
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        
                        let token = try decoder.decode(Token.self, from: data)
                        continuation.resume(with: .success(token))
                    } catch {
                        continuation.resume(with: .failure(error))
                    }
                } else if let error = error {
                    continuation.resume(with: .failure(error))
                }
            }.resume()
        }
    }
    func fetchNearByStops(completion: @escaping (Result<[Station], Error>) -> Void) {
        var urlComponet = URLComponents(string: "https://ptx.transportdata.tw/MOTC/v2/Bus/Station/NearBy")
        urlComponet?.queryItems = [
            URLQueryItem(name: "$spatialFilter", value: "nearby(25.0392167, 121.445724, 300)"),
            URLQueryItem(name: "$format", value: "JSON")
        ]
        
        guard let url = urlComponet?.url else {
            print("invalid url")
            return
        }
        var request = URLRequest(url: url)
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("url \(url)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                print("error \(error)")
            }
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let stations = try decoder.decode([Station].self, from: data)
                    completion(.success(stations))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
        
    }
    
    func fetchNearByStops(coordinate: (Double, Double), token: Token) async throws -> [Station] {
        var urlComponet = URLComponents(string: "https://tdx.transportdata.tw/api/advanced/v2/Bus/Station/NearBy")
        urlComponet?.queryItems = [
            URLQueryItem(name: "$spatialFilter", value: "nearby(\(coordinate.0), \(coordinate.1), 300)"),
            URLQueryItem(name: "$format", value: "JSON")
        ]
        
        guard let url = urlComponet?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        
                        let stationsResponse = try decoder.decode([Station].self, from: data)
                        continuation.resume(with: .success(stationsResponse))
                    } catch {
                        continuation.resume(with: .failure(error))
                    }
                } else if let error = error {
                    continuation.resume(with: .failure(error))
                }
            }.resume()
        }
    }
    func fetchArrivalTimeAsync(city: String, stationID: String, token: Token) async throws -> [ArrivalTime] {

        var urlComponet = URLComponents(string: "https://tdx.transportdata.tw/api/advanced/v2/Bus/EstimatedTimeOfArrival/City/\(city)/PassThrough/Station/\(stationID)")
        urlComponet?.queryItems = [
            URLQueryItem(name: "$top", value: "30"),
            URLQueryItem(name: "$format", value: "JSON")
        ]
        
        guard let url = urlComponet?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        
                        let arrivalTimeResponse = try decoder.decode([ArrivalTime].self, from: data)
                        continuation.resume(with: .success(arrivalTimeResponse))
                    } catch {
                        continuation.resume(with: .failure(error))
                    }
                } else if let error = error {
                    continuation.resume(with: .failure(error))
                }
            }.resume()
        }
    }
    
    func getDistrictAsync(coordinate: (Double, Double), token: Token) async throws -> District {
        //https://tdx.transportdata.tw/api/advanced/V3/Map/GeoLocating/District/LocationX/121.7062/LocationY/25.1357?%24format=JSON
        let (lat, lon) = coordinate
        var urlComponet = URLComponents(string: "https://tdx.transportdata.tw/api/advanced/V3/Map/GeoLocating/District/LocationX/\(lon)/LocationY/\(lat)")
        urlComponet?.queryItems = [
            URLQueryItem(name: "$format", value: "JSON")
        ]
        
        guard let url = urlComponet?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        
                        let districtResponse = try decoder.decode([District].self, from: data)
                        continuation.resume(with: .success(districtResponse[0]))
                    } catch {
                        continuation.resume(with: .failure(error))
                    }
                } else if let error = error {
                    continuation.resume(with: .failure(error))
                }
            }.resume()
        }
    }
    func fetchArrivalTimeForRouteNameAsync(cityName: String, routeName: String, token: Token) async throws -> [ArrivalTime] {
        //https://tdx.transportdata.tw/api/basic/v2/Bus/EstimatedTimeOfArrival/City/NewTaipei/99?%24filter=RouteName%2FZh_tw%20eq%20%2799%27&%24orderby=StopID&%24format=JSON
        
       
        var urlComponet = URLComponents(string: "https://tdx.transportdata.tw")!
        let path = "/api/basic/v2/Bus/EstimatedTimeOfArrival/City/\(cityName)/\(routeName)"
        urlComponet.path = path
        urlComponet.queryItems = [
            URLQueryItem(name: "$filter", value: "RouteName/Zh_tw eq '\(routeName)'"),
            URLQueryItem(name: "$orderby", value: "StopID"),
            URLQueryItem(name: "$format", value: "JSON")
        ]
        
        guard let url = urlComponet.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        
                        let arrivalTimeResponse = try decoder.decode([ArrivalTime].self, from: data)
                        continuation.resume(with: .success(arrivalTimeResponse))
                    } catch {
                        continuation.resume(with: .failure(error))
                    }
                } else if let error = error {
                    continuation.resume(with: .failure(error))
                }
            }.resume()
        }
    }
    
    func fetchStopsAsync(cityName: String, routeName: String, token: Token) async throws -> [StopOfRoute] {
        // https://tdx.transportdata.tw/api/basic/v2/Bus/StopOfRoute/City/NewTaipei/99?%24filter=RouteName%2FZh_tw%20eq%20%2799%27&%24format=JSON

        var urlComponet = URLComponents(string: "https://tdx.transportdata.tw")!
        let path = "/api/basic/v2/Bus/StopOfRoute/City/\(cityName)/\(routeName)"
        urlComponet.path = path
        
        urlComponet.queryItems = [
            URLQueryItem(name: "$filter", value: "RouteName/Zh_tw eq '\(routeName)'"),
            URLQueryItem(name: "$format", value: "JSON")
        ]
        
        guard let url = urlComponet.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        
                        let stopsResponse = try decoder.decode([StopOfRoute].self, from: data)
                        continuation.resume(with: .success(stopsResponse))
                    } catch {
                        continuation.resume(with: .failure(error))
                    }
                } else if let error = error {
                    continuation.resume(with: .failure(error))
                }
            }.resume()
        }
    }
    enum NetworkError: Error {
        case invalidURL
    }
}


