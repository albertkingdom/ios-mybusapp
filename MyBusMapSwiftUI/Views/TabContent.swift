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

struct TabContent: View {
    var viewModel = ArrivalTimeSheetViewModel.shared
    @ObservedObject var mapViewModel = MapViewModel.shared
    @State var arrivalTimes: [ArrivalTime]
    @Binding var push: Bool
    let clickOnRouteName: (String) -> Void
    let rowContent: RowContent
    @Binding var isLogin: Bool

    
    var body: some View {
        if #available(iOS 15.0, *) {
            List(arrivalTimes, id:\.id) { arrivalTime in
                HStack {
                    Text(calcEstimateTime(stopStatus: arrivalTime.stopStatus, estimateTime: arrivalTime.estimateTime ?? 0))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding()
                        .frame(width: 90, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.gray, lineWidth: 2)
                        )
                    VStack(alignment: .leading) {
                        switch rowContent {
                        case .routeName:
                            Text("\(arrivalTime.routeName.zhTw)")
                        case .stopName:
                            Text("\(arrivalTime.stopName.zhTw)")
                        }
                        
                        
                    }
                    Spacer()
                    
                 
                    
                    Aux(rowContent: rowContent,
                        arrivalTime: arrivalTime,
                      
                        
                        isSaved: checkStatus(stopID: arrivalTime.stopID, routeName: arrivalTime.routeName.zhTw, isLogin: isLogin),
                        isLogin: $isLogin
                    )
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    print("on tap route name")
                    withAnimation(.default) {
                        push.toggle()
                    }
                    let routeName = arrivalTime.routeName.zhTw
                    clickOnRouteName(routeName)
                }
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .navigationBarHidden(true)
            //.frame(height: 400, alignment: Alignment.topLeading)
            .onAppear {
                //print("savedStopID \(viewModel.savedStopID)")
                print("tab content update")
            }
            
            
        } else {
            // Fallback on earlier versions
            List(arrivalTimes, id:\.id) { arrivalTime in
                HStack {
                    Text(calcEstimateTime(stopStatus: arrivalTime.stopStatus, estimateTime: arrivalTime.estimateTime ?? 0))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding()
                        .frame(width: 90)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.gray, lineWidth: 2)
                        )
                    VStack(alignment: .leading) {
                        switch rowContent {
                        case .routeName:
                            Text("\(arrivalTime.routeName.zhTw)")
                        case .stopName:
                            Text("\(arrivalTime.stopName.zhTw)")
                        }
                        
                    }
                    Spacer()
                    switch rowContent {
                    case .routeName:
                        Image(systemName: "heart")
                    case .stopName:
                        PlateView(estimateTime: arrivalTime.estimateTime)
                    
                    }
                }
                .onTapGesture {
                    print("on tap route name")
                    withAnimation(.default) {
                        push.toggle()
                    }
                    let routeName = arrivalTime.routeName.zhTw
                    clickOnRouteName(routeName)
                }
            }
            .listStyle(.plain)
            .navigationBarHidden(true)
            //.frame(height: 100, alignment: Alignment.bottom)
            
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
            if isLogin && mapViewModel.remotwFavoriteRouteNames.contains(routeName) {
                return true
            }
            if !isLogin && viewModel.localSavedRouteName.contains(routeName) {
                return true
            }
        }
        return false
    }
   
}
// 愛心(實心、空心) or 車牌
struct Aux: View {
    let rowContent: RowContent
    let arrivalTime: ArrivalTime
    //let saveStop: ([String: String], String) -> Void
    //let removeSaveStop: ([String: String], String) -> Void
    @State var isSaved: Bool
    @Binding var isLogin: Bool
    
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
                            UserDefaultManager.shared.removeSaveStopFromLocal(target: favorite)
                        }
                        isSaved.toggle()
                    }
            } else {
                Image(systemName: "heart")
                    .onTapGesture {
                        print("click heart")
                        // add to user default

                        let favorite = Favorite(name: arrivalTime.routeName.zhTw, stationID: "")
                        if isLogin {
                            print("isLogin save to remote")
                            FirebaseManager.shared.saveToRemote(favorite: favorite)
                            
                        } else {
                            print("is not Login save to local")
                            UserDefaultManager.shared.saveStopToLocal(info: favorite)
                            
                        }
                        isSaved.toggle()
                    }
            }

            
            
        case .stopName:
            PlateView(estimateTime: arrivalTime.estimateTime)
        
        }
    }
}
struct TabContent_Previews: PreviewProvider {
    static var previews: some View {
        TabContent(arrivalTimes: [
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
                   clickOnRouteName: {_ in },
                   rowContent: .routeName,
                   isLogin: .constant(false)
                //savedStopID: ["1003"]
        )
    }
    
    
}
