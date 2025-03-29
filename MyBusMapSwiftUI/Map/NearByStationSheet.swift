//
//  FlexibleSheet.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/27/22.
//
import SwiftUI



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
        BottomSheetView(content: {
            Text("附近站牌")
                .multilineTextAlignment(.leading)
            if #available(iOS 15.0, *) {
               stationList
                    .listRowSeparator(.hidden)
            } else {
                stationList
            }
        }, onClose: {})
        
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
            , clickOnStationName: { _ in print("")}
        )
    }
}
