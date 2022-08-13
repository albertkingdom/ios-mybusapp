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
    @State var sheetMode: SheetMode = .half {
        didSet {
            draggedOffset = calculateOffset()
        }
    }
    @State var draggedOffset: CGFloat = UIScreen.main.bounds.height/2
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
        guard let arrivalTimes = arrivalTimes[0] else {
            return ""
        }
        return arrivalTimes[0].stopName.zhTw
    }
    
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
                                               //savedStopID: viewModel.savedStopID
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
        .padding(.top)
        .background(Color.white)
        .cornerRadius(15)
        .offset(y: draggedOffset)
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
        .onAppear {
            getSavedStop()
        }
        
    }
    func getSavedStop() {
        if mapViewModel.isLogin {
            viewModel.getLocalSavedFavList()
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

