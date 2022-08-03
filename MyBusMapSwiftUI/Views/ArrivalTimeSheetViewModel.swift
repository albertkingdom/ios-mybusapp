//
//  ArrivalTimeSheetViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/2/22.
//

import Foundation

class ArrivalTimeSheetViewModel: NSObject, ObservableObject {
    static let shared = ArrivalTimeSheetViewModel()
    let userdefault = UserDefaults.standard
    var savedList: [[String:String]] = [] {
        didSet {
            savedStopID = savedList.map { $0["stopID"] ?? ""}
        }
    }
//    var savedStopID: [String] {
//        var ids = [String]()
//        ids = savedList.map { $0["stopID"] ?? ""}
//        print(ids)
//        return ids
//
//    }
    @Published var savedStopID: [String] = []
    
    func getSavedStop() {
        //print("getSavedStop from ArrivalTimeSheetViewModel")
        
        if let existingSavedObj = userdefault.object(forKey: "favorite"),
            let existingList = existingSavedObj as? [[String: String]]{
            print("getSavedStop from ArrivalTimeSheetViewModel \(existingList)")
            savedList = existingList
        }
    }
}
