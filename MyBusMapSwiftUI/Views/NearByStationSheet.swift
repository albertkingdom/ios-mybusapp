//
//  FlexibleSheet.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/27/22.
//
import SwiftUI

enum SheetMode {
    case quarter
    case half
    case full
}

struct NearByStationSheet: View {
    @State var isloading = true
    @State var sheetMode: SheetMode = .half {
        didSet {
            //            draggedOffset = calculateOffset()
            calculateHeight()
        }
    }
//    @State var draggedOffset: CGFloat = UIScreen.main.bounds.height/2
    //@Binding var sheetMode: SheetMode
    @Binding var nearByStations: [NearByStation]
    @Binding var showNearByStationSheet: Bool
    let clickOnStationName: ([SubStation]) -> Void
    @State var heightFraction=0.4
    @State var viewH: Double=0.0
    @Binding var dynamicHeight: Double

    private func calculateHeight() {
        
        switch sheetMode {
            case .quarter:
            heightFraction=0.2
            dynamicHeight=viewH*heightFraction
            case .half:
            heightFraction=0.4
            dynamicHeight=viewH*heightFraction

            case .full:
            heightFraction=1
            dynamicHeight=viewH*heightFraction

        }
        print("dynamicHeight \(dynamicHeight)")
        
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
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(width: 50, height: 5, alignment: .center)
                            .foregroundColor(.gray)
                            .padding(.bottom)
                        
                    }
                    

                    Text("附近站牌")
                        .multilineTextAlignment(.leading)
                    
                    if #available(iOS 15.0, *) {
                        List(nearByStations, id:\.id) { station in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(station.stationName)")
                                    Text("\(station.subStations.count)個站牌")
                                        .foregroundColor(Color.secondary)
                                        .font(Font.system(size: 14))
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("tap on station name!")
                                showNearByStationSheet = false
                                clickOnStationName(station.subStations)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        
                        
                    } else {
                        // Fallback on earlier versions
                        List(nearByStations, id:\.id) { station in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(station.stationName)")
                                    Text("\(station.subStations.count)個站牌")
                                        .foregroundColor(Color.secondary)
                                        .font(Font.system(size: 14))
                                }
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("tap on station name!")
                                showNearByStationSheet = false
                                
                                clickOnStationName(station.subStations)
                            }
                            
                        }
                        .listStyle(.plain)
                        
                    }
                    
                    
                }
                .frame(height: geometry.size.height*heightFraction)
                .padding(.top)
                .background(Color.white)
                .cornerRadius(15)

        //        .offset(y: draggedOffset)
                
                .ignoresSafeArea(edges: [.bottom])
                .compositingGroup()
                .shadow(color: .black, radius: 4, x: 0, y: -1)
                .mask(Rectangle()
                        .padding(.top, -20))
                .gesture(
                    DragGesture()
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
            .onAppear{
                self.viewH = geometry.size.height*heightFraction
            }
            .onChange(of: geometry.size.height) { newSize in
                print("new H value \(newSize)")
                viewH = newSize*heightFraction
            }
        }
        
       
        
        
    }
    
    
}

struct NearByStationSheet_Previews: PreviewProvider {
    
    static var previews: some View {
//        FlexibleSheet(sheetMode: .constant(.none)) {
//            VStack {
//                Text("Hello World")
//            }.frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.blue)
        //            .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
        
        NearByStationSheet(
            //sheetMode: .constant(.full),
            nearByStations: .constant([
            NearByStation(stationName: "Test A", subStations: [
                SubStation(stationID: "111",
                           stationPosition: StationPosition(positionLon: 25, positionLat: 120, geoHash: "aaa"),
                           stationAddress: "Taipei",
                           routes: ["299", "307"])
            ])
            
        ]), showNearByStationSheet: .constant(true)
                      , clickOnStationName: { _ in print("")},
            dynamicHeight: .constant(0.0)
        )
    }
}
