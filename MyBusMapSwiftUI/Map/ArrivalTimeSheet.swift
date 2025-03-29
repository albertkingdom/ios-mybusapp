//
//  ArrivalTimeSheet.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/27/22.
//

import SwiftUI
import CoreLocation

struct ArrivalTimeSheet: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var authManager: AuthManager
    @StateObject var viewModel: ArrivalTimeSheetViewModel
 
    @State private var selectedTab: Int = 0
    @Binding var push: Bool
    @Binding var showNearByStationSheet: Bool
    //    let clickOnRouteName: (String) -> Void
    let unHighlightMarkers: () -> Void
    let clearData: () -> Void
    
    var directionTabs: [Tab] {
        var tabs: [Tab] = []
        for time in viewModel.sortedArrivalTimes.keys {
            let tab = Tab(icon: Image(systemName: "music.note"), title: time == 0 ? "去" : "回")
            tabs.append(tab)
        }
        return tabs
    }
    var title: String {
        guard let arrivalTimeList = viewModel.sortedArrivalTimes[0], !arrivalTimeList.isEmpty else {
            return ""
        }
        return arrivalTimeList[0].stopName.zhTw
    }
    // 切換"去程", "回程"
    var directionRow: some View {
        NavigationView {
            GeometryReader { geo in
                Tabs(tabs: directionTabs, geoWidth: geo.size.width, selectedTab: $selectedTab)
            }
        }
        .frame(height: 50)
        
    }
    
    
    @State private var timeRemaining = 0 // 倒數計時30sec 下次更新到站時間
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        BottomSheetView (content: {
            Text("\(title) 到站時間")
            Text("\(timeRemaining)秒後更新")
                .font(.system(size: 12))
            VStack(spacing: 0) {
                directionRow
                if viewModel.isLoading {
                    VStack {
                        HStack {
                            ProgressView()
                                .scaleEffect(2)
                                .progressViewStyle(.circular)
                                .offset(y: -30)
                        }
                        Spacer()
                    }
                }
                if !viewModel.isLoading {
                    // Views
                    TabView(selection: $selectedTab) {
                        ForEach(viewModel.sortedArrivalTimes.keys.sorted(), id: \.self) { key in
                            TimeListView(
                                remoteFavoriteRouteNames: viewModel.remoteFavoriteRouteNames,
                                arrivalTimes: viewModel.sortedArrivalTimes[key] ?? [],
                                push: $push,
                                //                                               clickOnRouteName: clickOnRouteName,
                                rowContent: .routeName,
                                isLogin: authManager.isLogin
                            )
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
        },
                         onClose: {
            print("On tap button")
            showNearByStationSheet = true
            unHighlightMarkers()
            // clean the arrivaltime data
            clearData()
        })
        .onAppear{
            viewModel.getRemoteData()
        }
        .onReceive(timer) { time in
            guard isActive, !viewModel.isLoading else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                Task {
                    await viewModel.fetchArrivalTime()
                    timeRemaining = 30
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            print("newPhase", newPhase)
            if newPhase == .active {
                isActive = true
            } else {
                isActive = false
            }
        }
    }
}
enum RowContent {
    case routeName
    case stopName
}


#Preview {
    ArrivalTimeSheet(
        //sheetMode: .constant(.half),
        viewModel: ArrivalTimeSheetViewModel(
            location: CLLocation(latitude: 100, longitude: 90),
            stationID: ""
        ),
//        arrivalTimes: .constant([0:[
//            ArrivalTime(stopID: "100",
//                        stopName: Name(zhTw: "材試所", en: "材試所"),
//                        routeName: Name(zhTw: "99", en: "99"),
//                        direction: 0,
//                        stopStatus: 3,
//                        estimateTime: 1111,
//                        srcUpdateTime: "00000",
//                        updateTime: "000000")
//        ]]),
        push: .constant(false),
        showNearByStationSheet: .constant(false),
        //        clickOnRouteName: { _ in },
        unHighlightMarkers: {  },
        clearData: {}
    )
}
