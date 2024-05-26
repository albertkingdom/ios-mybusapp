//
//  Test.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/28/22.
//

import SwiftUI
import GoogleMaps

struct RouteSheet: View {
    @ObservedObject var mapViewModel = MapViewModel.shared
    @Binding var push: Bool
    @Binding var location: CLLocation?
    
    @State var draggedOffset: CGFloat = UIScreen.main.bounds.height/2
    var title: String
    @Binding var arrivalTimes: [Int:[ArrivalTime]]
    @Binding var stops: [Int: [StopForRouteName]]
    @State var frameH: Double=20.0 // 目前bottom sheet高度
    @State var maxViewH: Double=100.0 // bottom sheet高度上限
    let heightFraction=0.4
    
    var directionTabs: [Tab] {
        var tabs:[Tab] = []
        for time in arrivalTimes.keys {
            let tab = Tab(icon: Image(systemName: "music.note"), title: time == 0 ? "去" : "回")
            tabs.append(tab)
        }
        return tabs
    }
    @State private var selectedTab: Int = 0
    // 切換"去程", "回程"
    var directionRow: some View {
        NavigationView {
            GeometryReader { geo in
                Tabs(tabs: directionTabs, geoWidth: geo.size.width, selectedTab: $selectedTab)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                GoogleMapsRouteView(location: $location, stops: $stops)
                VStack {
                    Spacer()
                    VStack {
                        ZStack{
                            DragBar()
                            HStack {
                                Spacer()
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .onTapGesture {
                                        print("close Test")
                                        push = false
                                    }
                            }
                            .padding(.trailing)
                        }
                        Text("\(title)")
                        VStack(spacing: 0) {
                            directionRow
                            if mapViewModel.isLoading {
                                VStack{
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
                                                   clickOnRouteName: { _ in  },
                                                   rowContent: .stopName,
                                                   isLogin: $mapViewModel.isLogin)
                                    }
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            }
                        }
                    }
                    .frame(height: frameH)
                    .bottomSheetStyle()
                    .gesture(DragGesture()
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
                        self.maxViewH=geometry.size.height-50
                        print("RouteSheet初始高度 \(frameH) 最高\(maxViewH)")
                    }
                }
            }
        }
    }
}

struct Route_Previews: PreviewProvider {
    static var previews: some View {
        RouteSheet(push: .constant(false),
                   
                   location: .constant(CLLocation(latitude: 25, longitude: 120)),
                   title: "99",
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
                   stops: .constant([0:[
                    StopForRouteName(stopName: Name(zhTw: "材試所", en: "材試所"), stopSequence: 0, stopPosition: StopPosition(positionLon: 120, positionLat: 20, geoHash: ""))]])
        )
    }
}
