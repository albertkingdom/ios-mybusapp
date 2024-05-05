//
//  Test.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/28/22.
//

import SwiftUI
import GoogleMaps

struct RouteSheet: View {
    @StateObject var mapViewModel = MapViewModel.shared
    @Binding var push: Bool
    @Binding var location: CLLocation?
    
    @State var draggedOffset: CGFloat = UIScreen.main.bounds.height/2
    var title: String
    @Binding var arrivalTimes: [Int:[ArrivalTime]]
    @Binding var stops: [Int: [StopForRouteName]]
    @State var frameH: Double=20.0 // 目前bottom sheet高度
    @State var maxViewH: Double=100.0 // bottom sheet高度上限
    let heightFraction=0.4
    
    var tabs: [Tab] {
        var tabs:[Tab] = []
        for time in arrivalTimes.keys {
            let tab = Tab(icon: Image(systemName: "music.note"), title: time == 0 ? "去" : "回")
            tabs.append(tab)
        }
        return tabs
    }
    @State private var selectedTab: Int = 0
    
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .leading) {
                GoogleMapsRouteView(location: $location, stops: $stops)
                //.edgesIgnoringSafeArea(.top)
                VStack {
                    HStack {
                        
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .onTapGesture {
                                print("close Test")
                                push = false
                            }
                        Spacer()
                        
                        
                        
                    }
                    .padding(.top, 50)
                    .frame(height: 80)
                    Spacer()
                    
                    
                    
                    VStack {
                        ZStack {
                            Rectangle()
                                .frame(width: 50, height: 5, alignment: .center)
                                .foregroundColor(.gray)
                                .padding(.bottom)
                            
                            
                            HStack {
                                Spacer()
                                
                            }
                        }
                        
                        
                        Text("\(title)")
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
                                                           clickOnRouteName: { _ in  },
                                                           rowContent: .stopName,
                                                           isLogin: $mapViewModel.isLogin)
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
                    .gesture(DragGesture()
                        .onChanged{ value in
                            
                            print("draggedOffset \(value.translation)")
                            self.frameH = MyBusMapSwiftUI.onDrag(yTranslation: value.translation.height, frameH: self.frameH, maxViewH: self.maxViewH)
                        }
                        .onEnded{ value in
                            
                        }
                    )
                    .onAppear{
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
