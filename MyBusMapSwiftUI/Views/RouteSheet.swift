//
//  Test.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/28/22.
//

import SwiftUI
import GoogleMaps

struct RouteSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var mapViewModel: MapViewModel
    @ObservedObject var viewModel: RouteSheetViewModel
    @Binding var push: Bool
    @Binding var location: CLLocation?
    
    @State var draggedOffset: CGFloat = UIScreen.main.bounds.height/2
    var title: String
//    @Binding var arrivalTimes: [Int:[ArrivalTime]]
    @Binding var stops: [Int: [StopForRouteName]]
    @State var frameH: Double=20.0 // 目前bottom sheet高度
    @State var maxViewH: Double=100.0 // bottom sheet高度上限
    @State var offsetY = UIScreen.main.bounds.height * 0.5  {
        didSet {
            print("offsetY", offsetY)
        }
    }
    @State var lastOffsetY = UIScreen.main.bounds.height * 0.5
    let heightFraction=0.4
    
    var directionTabs: [Tab] {
        var tabs:[Tab] = []
        for time in viewModel.sortedArrivalTimesForRouteName.keys {
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
//                VStack {
//                    Spacer()
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
                                        presentationMode.wrappedValue.dismiss() 
                                    }
                            }
                            .padding(.trailing)
                        }
                        Text("123\(title)")
                        VStack(spacing: 0) {
//                            directionRow
//                                .border(.brown)
                            if viewModel.isLoading {
//                                VStack{
//                                    HStack {
//                                        ProgressView()
//                                            .scaleEffect(2)
//                                            .progressViewStyle(.circular)
//                                            .offset(y: -30)
//                                    }
//                                    Spacer()
//                                }
                            } else {
                                
                                // Views
                                TabView(selection: $selectedTab) {
                                    
//                                    ForEach(viewModel.sortedArrivalTimesForRouteName.keys.sorted(), id: \.self) { key in
//                                        TimeListView(
//                                            mapViewModel: mapViewModel, arrivalTimes: viewModel.sortedArrivalTimesForRouteName[key] ?? [],
//                                                   push: $push,
//                                                   clickOnRouteName: { _ in  },
//                                                   rowContent: .stopName,
//                                                   isLogin: $mapViewModel.isLogin)
//                                    }
                                    VStack(content: {
                                        /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                                            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 300)
                                    })
                                    .background(.black)
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                .onAppear()
                                .border(.red)
//                                .frame(height: frameH>100?frameH-100:)
//                                Spacer()
                            }
                        }
//                        .frame(maxHeight: .infinity)
                    }
                    
//                    .frame(height: frameH)
                    .bottomSheetStyle()
                    .offset(CGSize(width: 0, height: self.offsetY))

                    .gesture(
                        DragGesture()
                       
                            .onChanged { value in
                                               offsetY = lastOffsetY + value.translation.height
                                           }
                           .onEnded { _ in
                               lastOffsetY = offsetY // 保存結束時的位置，讓偏移值持續累加
                           }
                        
                    )
//                    .onAppear {
//                        Task {
//                            await viewModel.fetchArrivalTimeForRouteNameAsync()
//                        }
//                        self.frameH=geometry.size.height*heightFraction
//                        self.maxViewH=geometry.size.height
//                        self.offsetY=self.maxViewH*0.6
//                        print("初始高度 \(frameH) 最高\(maxViewH)")
//                    }
                    .onChange(of: geometry.size.height) { newSize in
                        print("new H value \(newSize)")
                    }
                
                
            }
        }
        .navigationBarBackButtonHidden()
    }
}

//struct Route_Previews: PreviewProvider {
//    static var previews: some View {
//        RouteSheet(
//            mapViewModel: MapViewModel(),
//            viewModel: RouteSheetViewModel(arrivalTimes: <#T##[Int : [ArrivalTime]]#>)
//            push: .constant(false),
//                   
//                   location: .constant(CLLocation(latitude: 25, longitude: 120)),
//                   title: "99",
//                   arrivalTimes: .constant([0:[
//                    ArrivalTime(stopID: "100",
//                                stopName: Name(zhTw: "材試所", en: "材試所"),
//                                routeName: Name(zhTw: "99", en: "99"),
//                                direction: 0,
//                                stopStatus: 3,
//                                estimateTime: 1111,
//                                srcUpdateTime: "00000",
//                                updateTime: "000000")
//                   ]]),
//                   stops: .constant([0:[
//                    StopForRouteName(stopName: Name(zhTw: "材試所", en: "材試所"), stopSequence: 0, stopPosition: StopPosition(positionLon: 120, positionLat: 20, geoHash: ""))]])
//        )
//    }
//}
