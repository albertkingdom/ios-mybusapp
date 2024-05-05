//
//  ArrivalTimeSheet.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/27/22.
//

import SwiftUI

struct ArrivalTimeSheet: View {
    @StateObject var viewModel = ArrivalTimeSheetViewModel.shared
    @ObservedObject var mapViewModel = MapViewModel.shared

    var heightFraction=0.4
    @State var frameH: Double=0.0 // 目前bottom sheet高度
    @State var maxViewH: Double=0.0 // bottom sheet高度上限
    @Binding var arrivalTimes: [Int:[ArrivalTime]]
    @State private var selectedTab: Int = 0
    @Binding var push: Bool
    @Binding var showNearByStationSheet: Bool
    let clickOnRouteName: (String) -> Void
    let unHighlightMarkers: () -> Void
    let clearData: () -> Void
    
    
    var tabs: [Tab] {
        var tabs:[Tab] = []
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
    
    
    
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(width: 50, height: 5, alignment: .center)
                            .foregroundColor(.gray)
                            .padding(.bottom)
                        
                        
                        HStack {
                            Spacer()
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width:20)
                                .onTapGesture {
                                    print("On tap button")
                                    showNearByStationSheet = true
                                    // unhighlight markers
                                    unHighlightMarkers()
                                    
                                    // clean the arrivaltime data
                                    clearData()
                                }
                        }
                        .padding(.trailing)
                    }
                    
                    
                    Text("\(title) 到站時間")
                    NavigationView {
                        GeometryReader { geo in
                            VStack(spacing: 0) {
                                // Tabs
                                Tabs(tabs: tabs, geoWidth: geo.size.width, selectedTab: $selectedTab)
                                if mapViewModel.isLoading {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(2)
                                            .progressViewStyle(.circular)
                                            .offset(y: -30)
                                    }
                                }
                                if !mapViewModel.isLoading {
                                    // Views
                                    TabView(selection: $selectedTab) {
                                        
                                        ForEach(arrivalTimes.keys.sorted(), id: \.self) { key in
                                            
                                            
                                            TabContent(arrivalTimes: arrivalTimes[key] ?? [],
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
                            //.navigationBarTitleDisplayMode(.inline)
                            //.navigationTitle("TabsSwiftUIExample")
                            //.ignoresSafeArea()
                            
                            
                        }
                    }
                }
                
                .frame(height: frameH)
                .padding(.top)
                .background(Color.white)
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .ignoresSafeArea(edges: [.bottom])
                .compositingGroup()
                .shadow(color: .gray, radius: 1, x: 0, y: -1)
                .mask(Rectangle()
                    .padding(.top, -20))
                .gesture(
                    DragGesture()
                        .onChanged{ value in
                            
                            self.frameH = MyBusMapSwiftUI.onDrag(yTranslation: value.translation.height, frameH: self.frameH, maxViewH: self.maxViewH)
                        }
                        .onEnded{ value in
                            
                        }
                )
                .onAppear {
                    self.frameH=geometry.size.height*heightFraction
                    self.maxViewH=geometry.size.height
                    print("初始高度 \(frameH) 最高\(maxViewH)")
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

