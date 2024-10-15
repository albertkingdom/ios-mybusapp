//
//  ArrivalTimeSheet.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/27/22.
//

import SwiftUI

struct DraggableModifier: ViewModifier {
    @Binding var frameH: CGFloat
    @State private var maxViewH: CGFloat = 0.0
    let heightFraction: CGFloat
    let onDrag: (CGFloat, CGFloat, CGFloat) -> CGFloat
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .frame(height: frameH)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            frameH = onDrag(value.translation.height, frameH, maxViewH)
                        }
                )
                .onAppear {
                    frameH = geometry.size.height * heightFraction
                    maxViewH = geometry.size.height
                    print("初始高度 \(frameH) 最高 \(maxViewH)")
                }
        }
    }
}

struct ArrivalTimeSheet: View {
    @ObservedObject var mapViewModel = MapViewModel.shared

    var heightFraction=0.4
    @State var frameH: Double=0.0 // 目前bottom sheet高度
    @State var maxViewH: Double=0.0 // bottom sheet高度上限
    @Binding var arrivalTimes: [Int: [ArrivalTime]]
    @State private var selectedTab: Int = 0
    @Binding var push: Bool
    @Binding var showNearByStationSheet: Bool
    let clickOnRouteName: (String) -> Void
    let unHighlightMarkers: () -> Void
    let clearData: () -> Void
    
    var directionTabs: [Tab] {
        var tabs: [Tab] = []
        for time in arrivalTimes.keys {
            let tab = Tab(icon: Image(systemName: "music.note"), title: time == 0 ? "去" : "回")
            tabs.append(tab)
        }
        return tabs
    }
    var title: String {
        guard let arrivalTimeList = arrivalTimes[0], !arrivalTimeList.isEmpty else {
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
    var closeButton: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 20)
            .onTapGesture {
                print("On tap button")
                showNearByStationSheet = true
                unHighlightMarkers()
                // clean the arrivaltime data
                clearData()
            }
    }
    
    @State private var timeRemaining = 30
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    ZStack {
                        DragBar()
                        HStack {
                            Spacer()
                            closeButton
                        }
                        .padding(.trailing)
                    }
                    Text("\(title) 到站時間")
                    Text("\(timeRemaining)秒後更新")
                        .font(.system(size: 12))
                    VStack(spacing: 0) {
                        directionRow
                        if mapViewModel.isLoading {
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
                        if !mapViewModel.isLoading {
                            // Views
                            TabView(selection: $selectedTab) {
                                ForEach(arrivalTimes.keys.sorted(), id: \.self) { key in
                                    TimeListView(arrivalTimes: arrivalTimes[key] ?? [],
                                               push: $push,
                                               clickOnRouteName: clickOnRouteName,
                                               rowContent: .routeName,
                                               isLogin: $mapViewModel.isLogin
                                    )
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        }
                    }
                }
                .frame(height: frameH)
                .bottomSheetStyle()
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.frameH = onDrag(
                                yTranslation: value.translation.height, 
                                frameH: self.frameH,
                                maxViewH: self.maxViewH
                            )
                        }
                )
                .onAppear {
                    self.frameH=geometry.size.height*heightFraction
                    self.maxViewH=geometry.size.height
                    print("初始高度 \(frameH) 最高\(maxViewH)")
                }
                .onReceive(timer) { time in
                    guard isActive, !mapViewModel.isLoading else { return }

                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        Task {
                            await mapViewModel.fetchArrivalTime()
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
                .onDisappear {
                    print("onDisappear")
//                    mapViewModel.stopfetchArrivalTimeRepeatedly()
                }
            }
        }
    }
}
enum RowContent {
    case routeName
    case stopName
}

struct ArrivalTimeSheet_Previews: PreviewProvider {
    static var previews: some View {
        ArrivalTimeSheet(
            //sheetMode: .constant(.half),
            arrivalTimes: .constant([0:[
                ArrivalTime(stopID: "100",
                            stopName: Name(zhTw: "材試所", en: "材試所"),
                            routeName: Name(zhTw: "99", en: "99"),
                            direction: 0,
                            stopStatus: 3,
                            estimateTime: 1111,
                            srcUpdateTime: "00000",
                            updateTime: "000000")
            ]]),
            push: .constant(false),
            showNearByStationSheet: .constant(false),
            clickOnRouteName: { _ in },
            unHighlightMarkers: {  },
            clearData: {}
        )
    }
}
