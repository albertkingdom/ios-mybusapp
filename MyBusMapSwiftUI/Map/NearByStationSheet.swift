//
//  NearByStationSheet.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/27/22.
//
import SwiftUI

// Custom ButtonStyle for list items to provide visual feedback on tap
struct ListItemHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear)
            .animation(.easeInOut(duration: 0.3), value: configuration.isPressed)
    }
}

struct ListItem: View {
    var title: String
    var subTitle: String
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(ListItemHighlightButtonStyle())
    }
}

struct NearByStationSheet: View {
    @Binding var nearByStations: [NearByStation]
    @Binding var showNearByStationSheet: Bool
    let clickOnStationName: (([SubStation]) -> Void)?

    var stationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(nearByStations, id: \.id) { station in
                    ListItem(
                        title: station.stationName,
                        subTitle: "\(station.subStations.count)個站牌",
                        onTap: {
                            Task { @MainActor in
                                // Allow a short moment for the visual feedback to register
                                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

                                showNearByStationSheet = false
                                clickOnStationName?(station.subStations)
                            }
                        }
                    )
                }
            }
        }
    }

    var body: some View {
        BottomSheetView(
            content: {
                Text("附近站牌")
                    .multilineTextAlignment(.leading)
                stationList
            },
            showCloseButton: false,
            onClose: {}
        )

    }
}

#Preview {
    NearByStationSheet(
        nearByStations: .constant([
            NearByStation(
                stationName: "Test A",
                subStations: [
                    SubStation(
                        stationID: "111",
                        stationPosition: StationPosition(
                            positionLon: 25,
                            positionLat: 120,
                            geoHash: "aaa"
                        ),
                        stationAddress: "Taipei",
                        routes: ["299", "307"]
                    )
                ]
            ),
            NearByStation(
                stationName: "Test B",
                subStations: [
                    SubStation(
                        stationID: "111",
                        stationPosition: StationPosition(
                            positionLon: 25,
                            positionLat: 120,
                            geoHash: "aaa"
                        ),
                        stationAddress: "Taipei",
                        routes: ["299", "307"]
                    )
                ]
            )
        ]),
        showNearByStationSheet: .constant(true),
        clickOnStationName: nil
    )
}
