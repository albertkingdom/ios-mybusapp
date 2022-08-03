//
//  TabContent.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/29/22.
//

import Foundation
import SwiftUI

struct TabContent: View {
    var viewModel = ArrivalTimeSheetViewModel.shared
    @State var arrivalTimes: [ArrivalTime]
    @Binding var push: Bool
    let clickOnRouteName: (String) -> Void
    let rowContent: RowContent
    //@State var savedStopID: [String]?
    
    var body: some View {
        if #available(iOS 15.0, *) {
            List(arrivalTimes, id:\.id) { arrivalTime in
                HStack {
                    Text(calcEstimateTime(stopStatus: arrivalTime.stopStatus, estimateTime: arrivalTime.estimateTime ?? 0))
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
                        saveStop: saveStop(info:stopID:),
                        removeSaveStop: removeSaveStop(info:stopID:),
                        isSaved: checkStatus(stopID: arrivalTime.stopID))
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
                print("savedStopID \(viewModel.savedStopID)")
            }
            
            
        } else {
            // Fallback on earlier versions
            List(arrivalTimes, id:\.id) { arrivalTime in
                HStack {
                    Text(calcEstimateTime(stopStatus: arrivalTime.stopStatus, estimateTime: arrivalTime.estimateTime ?? 0))
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
    
    private func saveStop(info: [String: String], stopID: String) {
        let userdefault = UserDefaults.standard
        if var existing = userdefault.object(forKey: "favorite") as? [[String: String]] {
            existing.append(info)
            userdefault.set(existing, forKey: "favorite")
        } else {
            userdefault.set([info], forKey: "favorite")
        }
        //savedStopID?.append(stopID)
        viewModel.getSavedStop()
        print("saveStop")
    }
    private func removeSaveStop(info: [String: String], stopID: String) {
        let userdefault = UserDefaults.standard
        if var existing = userdefault.object(forKey: "favorite") as? [[String: String]],
           let index = existing.firstIndex(of: info)
           //let indexOfStopID = savedStopID?.firstIndex(of: stopID)
        {
            //let index = existing.firstIndex(of: info)
            existing.remove(at: index)
            userdefault.set(existing, forKey: "favorite")
            viewModel.getSavedStop()
            //savedStopID?.remove(at: indexOfStopID)
            //viewModel.savedStopID.remove(at: 0)
        }
    }
    
    private func checkStatus(stopID: String) -> Bool {
        print("checkStatus")
        
//        if let savedStopID = savedStopID,
//           savedStopID.contains(stopID){
//            return true
//        }
        if viewModel.savedStopID.contains(stopID) {
            return true
        }
        return false
    }
   
}
// 愛心(實心、空心) or 車牌
struct Aux: View {
    let rowContent: RowContent
    let arrivalTime: ArrivalTime
    let saveStop: ([String: String], String) -> Void
    let removeSaveStop: ([String: String], String) -> Void
    @State var isSaved: Bool
    
    var body: some View {
        switch rowContent {
        case .routeName:
            if isSaved {
                Image(systemName: "heart.fill")
                    .onTapGesture {
                        let info = ["routeName": arrivalTime.routeName.zhTw,
                                    "stopID": arrivalTime.stopID,
                                    "stopName": arrivalTime.stopName.zhTw]
                        removeSaveStop(info, arrivalTime.stopID)
                        isSaved.toggle()
                    }
            } else {
                Image(systemName: "heart")
                    .onTapGesture {
                        // add to user default
                        let info = ["routeName": arrivalTime.routeName.zhTw,
                                    "stopID": arrivalTime.stopID,
                                    "stopName": arrivalTime.stopName.zhTw]
                        saveStop(info, arrivalTime.stopID)
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
                   rowContent: .routeName
                //savedStopID: ["1003"]
        )
    }
    
    
}
