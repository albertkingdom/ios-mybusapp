//
//  FlexibleSheet.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/27/22.
//
import SwiftUI

struct DragBar: View {
    var body: some View {
        Rectangle()
            .frame(width: 50, height: 5, alignment: .center)
            .foregroundColor(.gray)
            .padding(.bottom)
    }
}
extension View {
    func bottomSheetStyle() -> some View {
        padding(.top)
            .background(Color.white)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .ignoresSafeArea(edges: [.bottom])
        //                .compositingGroup()
            .shadow(color: .gray, radius: 1, x: 0, y: -1)
            .mask(Rectangle()
                .padding(.top, -20))
    }
    func onDrag(yTranslation: CGFloat, frameH: Double, maxViewH: Double) -> Double {
        if yTranslation > 0 {
            let newframeH=frameH-Double(yTranslation)
            if newframeH > 50 {
                return newframeH
            }
        }
        if yTranslation < 0 {
            if frameH < maxViewH {
                return frameH-Double(yTranslation)
            }
        }
        return frameH
    }
}
struct ListItem: View {
    var title: String
    var subTitle: String
    var onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                Text(subTitle)
                    .foregroundColor(Color.secondary)
                    .font(Font.system(size: 14))
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .listRowSeparator(.hidden)
    }
}
struct NearByStationSheet: View {
    @State var isloading = true
    @Binding var nearByStations: [NearByStation]
    @Binding var showNearByStationSheet: Bool
    let clickOnStationName: ([SubStation]) -> Void
    let heightFraction=0.4
    @Binding var dynamicHeight: Double
    @State var frameH: Double=0.0 // 目前bottom sheet高度
    @State var maxViewH: Double=0.0 // bottom sheet高度上限
    var stationList: some View {
        List(nearByStations, id: \.id) { station in
            ListItem(
                title: station.stationName,
                subTitle: "\(station.subStations.count)個站牌",
                onTap: {
                    print("tap on station name!")
                    showNearByStationSheet = false
                    clickOnStationName(station.subStations)
                }
            )
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    ZStack {
                       DragBar()
                    }
                    Text("附近站牌")
                        .multilineTextAlignment(.leading)
                    if #available(iOS 15.0, *) {
                       stationList
                            .listRowSeparator(.hidden)
                    } else {
                        stationList
                    }
                }
                .frame(height: frameH)
                .bottomSheetStyle()
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            print("draggedOffset \(value.translation)")
                            self.frameH = onDrag(
                                yTranslation: value.translation.height,
                                frameH: self.frameH,
                                maxViewH: self.maxViewH
                            )
                        }
                )
            }
            .onAppear {
                self.frameH=geometry.size.height*heightFraction
                self.maxViewH=geometry.size.height
                print("初始高度 \(frameH) 最高\(maxViewH)")
            }
            .onChange(of: geometry.size.height) { newSize in
                print("new H value \(newSize)")
            }
        }
    }
}

struct NearByStationSheet_Previews: PreviewProvider {
    static var previews: some View {
        NearByStationSheet(
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
