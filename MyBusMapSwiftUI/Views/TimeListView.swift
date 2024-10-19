//
//  TabContent.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/29/22.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import RealmSwift

struct TimeListItem: View {
    var status: String
    var title: String
    var arrivalTime: ArrivalTime
    var rowContent: RowContent
    var isLogin: Bool
    var isSaved: Bool
    var deleteFavFromDB: (String) -> Void
    var onTap: () -> Void

    var body: some View {
        HStack {
            Text(status)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding()
                .frame(width: 90, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray, lineWidth: 2)
                )
            VStack(alignment: .leading) {
                Text(title)
            }
            Spacer()
            Aux(rowContent: rowContent,
                arrivalTime: arrivalTime,
                isSaved: isSaved,
                isLogin: isLogin,
                deleteFavFromDB: deleteFavFromDB
               )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct TimeListView: View {
//    @ObservedObject var mapViewModel: MapViewModel
    @State var remoteFavoriteRouteNames: [String] = []
    @State var arrivalTimes: [ArrivalTime]
    @Binding var push: Bool
//    let clickOnRouteName: (String) -> Void
    let rowContent: RowContent
    var isLogin: Bool
    @State var realmFavList: Results<FavoriteRealm> = RealmManager.shared.readAllFromDB()
    var timeList: some View {
        List(arrivalTimes, id: \.id) { arrivalTime in
            let status = calcEstimateTime(
                stopStatus: arrivalTime.stopStatus,
                estimateTime: arrivalTime.estimateTime ?? 0)
            var title: String {
                switch rowContent {
                case .routeName:
                    return arrivalTime.routeName.zhTw
                case .stopName:
                    return arrivalTime.stopName.zhTw
                }
            }
            var isSaved: Bool {
                return checkStatus(stopID: arrivalTime.stopID, 
                                   routeName: arrivalTime.routeName.zhTw,
                                   isLogin: isLogin)
            }
  
            TimeListItem(status: status,
                         title: title,
                         arrivalTime: arrivalTime,
                         rowContent: rowContent,
                         isLogin: isLogin,
                         isSaved: isSaved,
                         deleteFavFromDB: deleteFavFromDB(routeName:),
                         onTap: {
                            print("on tap route name")
                            withAnimation(.default) {
                                push.toggle()
                            }
                            let routeName = arrivalTime.routeName.zhTw
//                            clickOnRouteName(routeName)
                        })
        }
        .border(.yellow)
        .listStyle(.plain)
        .listRowSeparator(.hidden)
        .navigationBarHidden(true)
        
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            timeList
            .listRowSeparator(.hidden)

        } else {
           timeList
        }
    }
    private func calcEstimateTime(stopStatus: Int, estimateTime: Int) -> String {
        var str = ""
        switch stopStatus {
        case 0:
            str = "\(Int(estimateTime/60))分"
        case 1:
            str = "未發車"
        case 2:
            str = "不停靠"
        case 3:
            str = "末班已過"
        case 4:
            str = "未營運"
        default:
            break
        }
        
        return str
    }
    

    private func checkStatus(stopID: String?, routeName: String?, isLogin: Bool) -> Bool {
        if let routeName = routeName {
            if isLogin && remoteFavoriteRouteNames.contains(routeName) {
                return true
            }
//            if !isLogin && viewModel.localSavedRouteName.contains(routeName) {
//                return true
//            }
            if !isLogin && realmFavList.contains(where: { item in
                item.name == routeName
            }) {
                return true
            }
        }
        return false
    }
    
    func deleteFavFromDB(routeName: String) {
        let favToDelete = realmFavList.first(where: {$0.name == routeName}) ?? FavoriteRealm()
        RealmManager.shared.deleteFromDB(objectToDelete: favToDelete)
    }
   
}
// 愛心(實心、空心) or 車牌
struct Aux: View {
    let rowContent: RowContent
    let arrivalTime: ArrivalTime
    @State var isSaved: Bool
    var isLogin: Bool
    let deleteFavFromDB: (String) -> Void
    
    var body: some View {
        switch rowContent {
        case .routeName:
            if isSaved {
                Image(systemName: "heart.fill")
                    .onTapGesture {

                        let favorite = Favorite(name: arrivalTime.routeName.zhTw, stationID: "")
                        
                        if isLogin {
                            FirebaseManager.shared.removeFromRemote(favorite: favorite)
                        } else {
                            deleteFavFromDB(arrivalTime.routeName.zhTw)
                        }
                        isSaved.toggle()
                    }
            } else {
                Image(systemName: "heart")
                    .onTapGesture {
                        print("click heart")
                        // add to user default

                        let favorite = Favorite(name: arrivalTime.routeName.zhTw, stationID: "")
                        let favoriteRealm = FavoriteRealm(name: arrivalTime.routeName.zhTw, stationID: "")
                        if isLogin {
                            print("isLogin save to remote")
                            FirebaseManager.shared.saveToRemote(favorite: favorite)
                            
                        } else {
                            print("is not Login save to local")
                            RealmManager.shared.saveToDB(favoriteRealm)
                        }
                        isSaved.toggle()
                    }
            }
          
        case .stopName:
            PlateView(estimateTime: arrivalTime.estimateTime)        
        }
    }
}
//struct TabContent_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeListView(arrivalTimes: [
//            ArrivalTime(stopID: "100",
//                        stopName: Name(zhTw: "材試所", en: "材試所"),
//                        routeName: Name(zhTw: "99", en: "99"),
//                        direction: 0,
//                        stopStatus: 3,
//                        estimateTime: 59,
//                        srcUpdateTime: "00000",
//                        updateTime: "000000"),
//            ArrivalTime(stopID: "101",
//                        stopName: Name(zhTw: "材試所", en: "材試所"),
//                        routeName: Name(zhTw: "99", en: "99"),
//                        direction: 0,
//                        stopStatus: 3,
//                        estimateTime: 120,
//                        srcUpdateTime: "00000",
//                        updateTime: "000000")
//        ],
//                   push: .constant(true),
//                   clickOnRouteName: {_ in },
//                   rowContent: .routeName,
//                   isLogin: .constant(false)
//        )
//    }
//}

#Preview {
    TimeListView(
        
        arrivalTimes: [
        ArrivalTime(stopID: "100",
                    stopName: Name(zhTw: "材試所", en: "材試所"),
                    routeName: Name(zhTw: "99", en: "99"),
                    direction: 0,
                    stopStatus: 3,
                    estimateTime: 59,
                    srcUpdateTime: "00000",
                    updateTime: "000000"),
        ArrivalTime(stopID: "101",
                    stopName: Name(zhTw: "材試所", en: "材試所"),
                    routeName: Name(zhTw: "99", en: "99"),
                    direction: 0,
                    stopStatus: 3,
                    estimateTime: 120,
                    srcUpdateTime: "00000",
                    updateTime: "000000")
    ],
               push: .constant(true),
//               clickOnRouteName: {_ in },
               rowContent: .routeName,
               isLogin: false
    )
}
