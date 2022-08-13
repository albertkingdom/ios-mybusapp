//
//  ArrivalTimeSheetViewModel.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 8/2/22.
//

import Foundation

class ArrivalTimeSheetViewModel: NSObject, ObservableObject {
    static let shared = ArrivalTimeSheetViewModel()
    var localSavedFavList: [Favorite] = [] {
        didSet {
            localSavedRouteName = localSavedFavList.compactMap({
                $0.name
            })
        }
    }

    @Published var localSavedRouteName: [String] = []
    //@Published var savedStopID: [String] = []
    func getLocalSavedFavList() {
        localSavedFavList = UserDefaultManager.shared.getSavedStopFromLocal()
    }
}
