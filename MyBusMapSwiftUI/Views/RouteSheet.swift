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
    @State var sheetMode: SheetMode = .half {
        didSet {
            draggedOffset = calculateOffset()
        }
    }
    @State var draggedOffset: CGFloat = UIScreen.main.bounds.height/2
    var title: String
    @Binding var arrivalTimes: [Int:[ArrivalTime]]
    @Binding var stops: [Int: [StopForRouteName]]

    var tabs: [Tab] {
        var tabs:[Tab] = []
        for time in arrivalTimes.keys {
            let tab = Tab(icon: Image(systemName: "music.note"), title: time == 0 ? "去" : "回")
            tabs.append(tab)
        }
        return tabs
    }
    @State private var selectedTab: Int = 0
    private func calculateOffset() -> CGFloat {
        
        switch sheetMode {
        case .quarter:
            return UIScreen.main.bounds.height*3/4
        case .half:
            return UIScreen.main.bounds.height/2
        case .full:
            return 0
        }
        
    }
    private func onDrag(yTranslation: CGFloat){
        if yTranslation > 0 {
            switch sheetMode {
            case .quarter:
                break
            case .half:
                sheetMode = .quarter
            case .full:
                sheetMode = .half
            }
            print("+y drag sheetMode \(sheetMode)")
        }
        if yTranslation < 0 {
            switch sheetMode {
            case .quarter:
                sheetMode = .half
            case .half:
                sheetMode = .full
            case .full:
                break
            }
            print("-y drag sheetMode \(sheetMode)")
        }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            GoogleMapsRouteView(location: $location, stops: $stops)
                //.edgesIgnoringSafeArea(.top)
            HStack {
                VStack {
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
                .padding()
                Spacer()
            }
            
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
            .padding(.top)
            .background(Color.white)
            .cornerRadius(15)
            .offset(y: draggedOffset)
            .ignoresSafeArea(edges: [.bottom])
            .compositingGroup()
            .shadow(color: .black, radius: 4, x: 0, y: -1)
            .mask(Rectangle()
                    .padding(.top, -20))
            .gesture(DragGesture()
                        .onChanged{ value in
                            
                            print("draggedOffset \(value.translation)")
                        }
                        .onEnded{ value in
                            onDrag(yTranslation: value.translation.height)
                            if value.translation.height > 0 {
                                print("drag end +y")
                                
                            }else {
                                print("drag end -y")
                            }
                        }
            )
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
