//
//  NetworkManager.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/26/22.
//

import Foundation
import SwiftUI
import Security
import CoreLocation

let cities = [
              "NewTaipei",
              "Taipei",
              "Taoyuan",
              "Taichung",
              "Tainan",
              "Kaohsiung",
              "Keelung",
              "Hsinchu",
              "HsinchuCounty",
              "MiaoliCounty",
              "ChanghuaCounty",
              "NantouCounty",
              "YunlinCounty",
              "ChiayiCounty",
              "Chiayi",
              "PingtungCounty",
              "YilanCounty",
              "HualienCounty",
              "TaitungCounty",
              "KinmenCounty",
              "PenghuCounty",
              "LienchiangCounty"]

class NetworkManager {
    var getData: (URLRequest) async throws -> Data
    static let shared = {
        let session = URLSession(configuration: .default)
        // 調用init()賦值getData
        return NetworkManager(getData: {request in
            try await session.data(for: request)
        })
    }()
    var token: Token?
    private let session = URLSession(configuration: .default)
//    private init() {
//            if let savedToken = retrieveTokenFromKeychain() {
//                self.token = savedToken
//            }
//    }
     private init(getData: @escaping (URLRequest) async throws -> Data) {
         self.getData = getData
         if let savedToken = retrieveTokenFromKeychain() {
             self.token = savedToken
         } else {
             print("no saved token in keychain")
         }
     }

//    static let stub = NetworkManager { request in
//        if request.url?.absoluteString.contains("token") == true {
//                        return NetworkManager.Endpoint.token.stub
//                    } else if request.url?.absoluteString.contains("NearBy") == true {
//                        return NetworkManager.Endpoint.nearByStops(coordinate: (0, 0)).stub
//                    }
//                    return Data()
//    }
    let clientID = Bundle.main.infoDictionary?["API_CLIENT_ID"] as? String
    let clientKey = Bundle.main.infoDictionary?["API_CLIENT_KEY"] as? String
    let SOURCE_URL = "https://tdx.transportdata.tw"
    var TOKEN_URL: String {
        return "\(SOURCE_URL)/auth/realms/TDXConnect/protocol/openid-connect/token"
    }
    var NEARBY_STOP_URL: String {
        return "\(SOURCE_URL)/api/advanced/v2/Bus/Station/NearBy"
    }
    var NEARBY_STOP_COORD_URL: String {
        return "\(SOURCE_URL)/api/advanced/v2/Bus/Station/NearBy"
    }
    
    func fetchNearByStops(coordinate: (Double, Double)) async throws -> [Station] {

        var request = NetworkManager.Endpoint.nearByStops(coordinate: coordinate).request
   
        let newToken = try await fetchToken()
  
    
        print("token \(newToken), \(coordinate)")
        request.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
        do {
            let data = try await getData(request)
            let decoder = JSONDecoder()
            let stationsResponse = try decoder.decode([Station].self, from: data)
            return stationsResponse
        } catch {
            print(error)
            throw NetworkError.invalidData
        }
    }
    func fetchArrivalTimeAsync(city: String, stationID: String) async throws -> [ArrivalTime] {
        
        print("station_id: \(stationID)")

        var urlComponent = URLComponents(string: "\(SOURCE_URL)/api/advanced/v2/Bus/EstimatedTimeOfArrival/City/\(city)/PassThrough/Station/\(stationID)")!
        urlComponent.queryItems = [
            URLQueryItem(name: "$top", value: "30"),
            URLQueryItem(name: "$format", value: "JSON")
        ]
        
        guard let url = urlComponent.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        let token = await checkToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let resp = response as? HTTPURLResponse else {
                    return
                }
                print(resp.statusCode)
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
    
    func fetchArrivalTimeForRouteNameAsync(cityName: String, routeName: String) async throws -> [ArrivalTime] {
        //https://tdx.transportdata.tw/api/basic/v2/Bus/EstimatedTimeOfArrival/City/NewTaipei/99?%24filter=RouteName%2FZh_tw%20eq%20%2799%27&%24orderby=StopID&%24format=JSON
        
        var urlComponent = URLComponents(string: "\(SOURCE_URL)/api/basic/v2/Bus/EstimatedTimeOfArrival/City/\(cityName)/\(routeName)")

        urlComponent?.queryItems = [
            URLQueryItem(name: "$filter", value: "RouteName/Zh_tw eq '\(routeName)'"),
            URLQueryItem(name: "$orderby", value: "StopID"),
            URLQueryItem(name: "$format", value: "JSON")
        ]
        
        guard let url = urlComponent?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        let token = await checkToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
    
    func fetchStopsAsync(cityName: String, routeName: String) async throws -> [StopOfRoute] {
        // https://tdx.transportdata.tw/api/basic/v2/Bus/StopOfRoute/City/NewTaipei/99?%24filter=RouteName%2FZh_tw%20eq%20%2799%27&%24format=JSON
        var urlComponent = URLComponents(string: "\(SOURCE_URL)/api/basic/v2/Bus/StopOfRoute/City/\(cityName)/\(routeName)")
        
        urlComponent?.queryItems = [
            URLQueryItem(name: "$filter", value: "RouteName/Zh_tw eq '\(routeName)'"),
            URLQueryItem(name: "$format", value: "JSON")
        ]

        guard let url = urlComponent?.url else {
            print("fetchStopsAsync invalid URL")
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        let token = await checkToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, _, error in
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
   
}
enum NetworkError: Error {
    case invalidURL
    case missingApiKey
    case invalidCode(Int)
    case invalidData
    case invalidCity
}

extension NetworkManager {
    private func saveTokenToKeychain(token: Token) {
        do {
            let tokenData = try JSONEncoder().encode(token)
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "authToken",
                kSecValueData as String: tokenData
            ]
            
            // Delete any existing items
            SecItemDelete(query as CFDictionary)
            
            // Add the new token
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("Error saving token: \(status)")
            }
        } catch {
            print("\(error)")
        }
        
    }
    private func retrieveTokenFromKeychain() -> Token? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            
            if status == errSecItemNotFound {
                print("Token not found in Keychain")
            } else {
                print("Error retrieving token: \(status)")
            }
            return nil
        }
        
        
        guard let tokenData = item as? Data,
              let token = try? JSONDecoder().decode(Token.self, from: tokenData) else {
            return nil
        }
        
        return token
    }
    private func isTokenExpired(token: Token) -> Bool {
        let expirationDate = Date(timeIntervalSinceNow: TimeInterval(token.expiresIn))
        print("expirationDate \(expirationDate)")
        return Date() > expirationDate
    }
    func checkToken() async -> String {
        if token==nil || isTokenExpired(token: token!) {
            do {
                let newToken = try await fetchToken()
                print("got new token \(newToken)")
                return newToken
            } catch {
                print("\(error)")
            }
        }
        guard let token else {return ""}
        return token.accessToken
    }
    func fetchToken() async throws -> String {
        guard let url = URL(string: TOKEN_URL) else {
            throw NetworkError.invalidURL
        }
        guard let clientID = clientID,
              let clientKey = clientKey
        else { throw NetworkError.missingApiKey}

        let request = NetworkManager.Endpoint.token.request
        do {
            let data = try await getData(request)
            print("data \(data)")
            let decoder = JSONDecoder()
            let token = try decoder.decode(Token.self, from: data)
            saveTokenToKeychain(token: token)
            self.token = token
            print("saved token is \(token)")
            return token.accessToken
        } catch {
            print("fetchToken error \(error)")
        }
        return ""
    }
}

extension NetworkManager {
    enum Endpoint {
        case token
        case nearByStops(coordinate: (Double, Double))
        case arrivalTime(city: String, stationID: String)
        case district(coordinate: (Double, Double))
        case arrivalTimeForRouteName(cityName: String, routeName: String)
        case stops(cityName: String, routeName: String)
        var TOKEN_URL: String {
            return "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token"
        }
        var NEARBY_STOP_URL: String {
            return "https://tdx.transportdata.tw/api/advanced/v2/Bus/Station/NearBy"
        }
        var SOURCE_URL: String {
            return "https://tdx.transportdata.tw"
        }
        var request: URLRequest {
            switch self {
            case .token:
                guard let clientID = Bundle.main.infoDictionary?["API_CLIENT_ID"] as? String,
                      let clientKey = Bundle.main.infoDictionary?["API_CLIENT_KEY"] as? String
                else {
                    fatalError()
                }
                let url = URL(string: TOKEN_URL)!
                var request = URLRequest(url: url)
                request.httpMethod = "post"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                let parameters = "grant_type=client_credentials&client_id=\( clientID)&client_secret=\(clientKey)"
                let postData =  parameters.data(using: .utf8)
                request.httpBody = postData
                return request
            case .nearByStops(let coordinate):
                var urlComponet = URLComponents(string: NEARBY_STOP_URL)
                urlComponet?.queryItems = [
                    URLQueryItem(name: "$spatialFilter", value: "nearby(\(coordinate.0), \(coordinate.1), 300)"),
                    URLQueryItem(name: "$format", value: "JSON")
                ]
                
                let url = urlComponet!.url
                print("nearByStops url: \(url)")
                
                //                let token = await checkToken()
                //                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                return URLRequest(url: url!)
                
            case .arrivalTime(let city, let stationID):
                var urlComponent = URLComponents(string: "https://tdx.transportdata.tw/api/advanced/v2/Bus/EstimatedTimeOfArrival/City/\(city)/PassThrough/Station/\(stationID)"
                )!
                urlComponent.queryItems = [
                    URLQueryItem(name: "$top", value: "30"),
                    URLQueryItem(name: "$format", value: "JSON")
                ]
                let url = urlComponent.url!
                
                return URLRequest(url: url)
            case .arrivalTimeForRouteName(let cityName, let routeName):
                var urlComponent = URLComponents(string: "\(SOURCE_URL)/api/basic/v2/Bus/EstimatedTimeOfArrival/City/\(cityName)/\(routeName)")!

                urlComponent.queryItems = [
                    URLQueryItem(name: "$filter", value: "RouteName/Zh_tw eq '\(routeName)'"),
                    URLQueryItem(name: "$orderby", value: "StopID"),
                    URLQueryItem(name: "$format", value: "JSON")
                ]
                
                let url = urlComponent.url!
                
                return URLRequest(url: url)
            case .stops(let cityName, let routeName):
                var urlComponent = URLComponents(string: "\(SOURCE_URL)/api/basic/v2/Bus/StopOfRoute/City/\(cityName)/\(routeName)")!
                
                urlComponent.queryItems = [
                    URLQueryItem(name: "$filter", value: "RouteName/Zh_tw eq '\(routeName)'"),
                    URLQueryItem(name: "$format", value: "JSON")
                ]

                let url = urlComponent.url!
                return URLRequest(url: url)
            case .district(let coordinate):
                let (lat, lon) = coordinate
               
                var urlComponent = URLComponents(string: "\(SOURCE_URL)/api/advanced/V3/Map/GeoLocating/District/LocationX/\(lon)/LocationY/\(lat)")!

                urlComponent.queryItems = [
                    URLQueryItem(name: "$format", value: "JSON")
                ]
                let url = urlComponent.url!
                
                return URLRequest(url: url)
            }
        }
    }
}


extension NetworkManager.Endpoint {
    var stub: Data {
        let string: String
        switch self {
        case .token:
            string = """
{
    "access_token":"xxxxxx",
    "expires_in":128888888
}
"""
        case .nearByStops:
            string = """
[
  {
    "StationUID": "string",
    "StationID": "string",
    "StationName": {
      "Zh_tw": "string",
      "En": "string"
    },
    "StationPosition": {
      "PositionLon": 0,
      "PositionLat": 0,
      "GeoHash": "string"
    },
    "StationAddress": "string",
    "StationGroupID": "string",
    "Stops": [
      {
        "StopUID": "string",
        "StopID": "string",
        "StopName": {
          "Zh_tw": "string",
          "En": "string"
        },
        "RouteUID": "string",
        "RouteID": "string",
        "RouteName": {
          "Zh_tw": "string",
          "En": "string"
        }
      }
    ],
    "LocationCityCode": "string",
    "Bearing": "string",
    "UpdateTime": "2024-05-26T14:01:02.383Z",
    "VersionID": 0
  }
]
"""
        case .arrivalTime(let city, let stationID):
            string = """
[
  {
    "StopUID": "TPE134741",
    "StopID": "134741",
    "StopName": {
      "Zh_tw": "幸福東路",
      "En": "Xingfu  E. Rd."
    },
    "RouteUID": "TPE11411",
    "RouteID": "11411",
    "RouteName": {
      "Zh_tw": "299",
      "En": "299"
    },
    "Direction": 0,
    "EstimateTime": 983,
    "StopStatus": 0,
    "SrcUpdateTime": "2024-05-27T21:40:40+08:00",
    "UpdateTime": "2024-05-27T21:40:42+08:00"
  }
]
"""
        case .stops(let cityName, let routeName):
            string = """
[
  {
    "PlateNumb": "string",
    "StopUID": "string",
    "StopID": "string",
    "StopName": {
      "Zh_tw": "string",
      "En": "string"
    },
    "RouteUID": "string",
    "RouteID": "string",
    "RouteName": {
      "Zh_tw": "string",
      "En": "string"
    },
    "SubRouteUID": "string",
    "SubRouteID": "string",
    "SubRouteName": {
      "Zh_tw": "string",
      "En": "string"
    },
    "Direction": 0,
    "EstimateTime": 0,
    "StopCountDown": 0,
    "CurrentStop": "string",
    "DestinationStop": "string",
    "StopSequence": 0,
    "StopStatus": 0,
    "MessageType": 0,
    "NextBusTime": "2024-05-27T13:44:13.105Z",
    "IsLastBus": true,
    "Estimates": [
      {
        "PlateNumb": "string",
        "EstimateTime": 0,
        "IsLastBus": true,
        "VehicleStopStatus": 0
      }
    ],
    "DataTime": "2024-05-27T13:44:13.105Z",
    "TransTime": "2024-05-27T13:44:13.105Z",
    "SrcRecTime": "2024-05-27T13:44:13.105Z",
    "SrcTransTime": "2024-05-27T13:44:13.105Z",
    "SrcUpdateTime": "2024-05-27T13:44:13.105Z",
    "UpdateTime": "2024-05-27T13:44:13.105Z"
  }
]
"""
        case .arrivalTimeForRouteName(_, _):
            string = """
[
  {
    "StopUID": "TPE134741",
    "StopID": "134741",
    "StopName": {
      "Zh_tw": "幸福東路",
      "En": "Xingfu  E. Rd."
    },
    "RouteUID": "TPE11411",
    "RouteID": "11411",
    "RouteName": {
      "Zh_tw": "299",
      "En": "299"
    },
    "Direction": 0,
    "EstimateTime": 983,
    "StopStatus": 0,
    "SrcUpdateTime": "2024-05-27T21:40:40+08:00",
    "UpdateTime": "2024-05-27T21:40:42+08:00"
  }
]
"""
        case .district(let coordinate):
            string = """
[
    "City":
]
"""
        }

        return Data(string.utf8)
    }
}

extension NetworkManager {
    // 用內建服務取得城市名字
    func getDistrictAsync(from coordinate: (Double, Double)) async throws -> String {
        let geocoder = CLGeocoder()
        let (lat, lon) = coordinate

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon) // Taipei coordinates

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "en-US"))
            if let placemark = placemarks.first {
                var cityName = placemark.subAdministrativeArea!
                print("cityName \(cityName)")
                if let targetCityName = cities.first(where: { city in
                    return cityName.replacingOccurrences(of: " ",with: "").contains(city)
                }) {
                    print("targetCityName \(String(describing: targetCityName))")
                    return targetCityName
                }
            }
            return ""
        } catch {
            print("Failed to reverse geocode location: \(error.localizedDescription)")
            throw NetworkError.invalidCity
        }
    }
}
