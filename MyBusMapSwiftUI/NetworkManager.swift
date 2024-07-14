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
    static let shared = NetworkManager()
    private let session: URLSession
    private let tokenManager: TokenManager
    //    var getData: (URLRequest) async throws -> Data
    func getData(_ request: URLRequest) async throws -> Data {
        let token = try await tokenManager.getValidToken()
        var authenticatedRequest = request
        authenticatedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let data = try await session.data(for: authenticatedRequest)
        return data
    }
//    static let shared = {
//        let session = URLSession(configuration: .default)
//        // 調用init()賦值getData
//        return NetworkManager(getData: {request in
//            try await session.data(for: request)
//        })
//    }()
//    var token: Token?
//    private let session = URLSession(configuration: .default)
    //    private init() {
    //            if let savedToken = retrieveTokenFromKeychain() {
    //                self.token = savedToken
    //            }
    //    }
//    private init(getData: @escaping (URLRequest) async throws -> Data) {
//        self.getData = getData
//        if let savedToken = retrieveTokenFromKeychain() {
//            self.token = savedToken
//        } else {
//            print("no saved token in keychain")
//        }
//    }
    private init() {
        self.session = URLSession(configuration: .default)
        self.tokenManager = TokenManager(clientID: clientID, clientKey: clientKey)
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
        
        var request = NetworkManager.Endpoint.arrivalTime(city: city, stationID: stationID).request

        do {
            let data = try await getData(request)
            let decoder = JSONDecoder()
            let arrivalTimeResponse = try decoder.decode([ArrivalTime].self, from: data)
            return arrivalTimeResponse
        } catch {
            print(error)
            throw NetworkError.invalidData
        }
        
    }
    
    func fetchArrivalTimeForRouteNameAsync(cityName: String, routeName: String) async throws -> [ArrivalTime] {
        //https://tdx.transportdata.tw/api/basic/v2/Bus/EstimatedTimeOfArrival/City/NewTaipei/99?%24filter=RouteName%2FZh_tw%20eq%20%2799%27&%24orderby=StopID&%24format=JSON
        
        var request = NetworkManager.Endpoint.arrivalTimeForRouteName(cityName: cityName, routeName: routeName).request
        do {
            let data = try await getData(request)
            let decoder = JSONDecoder()
            let arrivalTimeResponse = try decoder.decode([ArrivalTime].self, from: data)
            return arrivalTimeResponse
        } catch {
            print(error)
            throw NetworkError.invalidData
        }
    }
    
    func fetchStopsAsync(cityName: String, routeName: String) async throws -> [StopOfRoute] {
        // https://tdx.transportdata.tw/api/basic/v2/Bus/StopOfRoute/City/NewTaipei/99?%24filter=RouteName%2FZh_tw%20eq%20%2799%27&%24format=JSON
        var request = NetworkManager.Endpoint.stops(cityName: cityName, routeName: routeName).request
        do {
            let data = try await getData(request)
            let decoder = JSONDecoder()
            let stopsResponse = try decoder.decode([StopOfRoute].self, from: data)
            return stopsResponse
        } catch {
            print(error)
            throw NetworkError.invalidData
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
