//
//  ListView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/31/22.
//

import SwiftUI

struct ListView: View {
    @StateObject var viewModel = MapViewModel.shared
    @State var push: Bool = false
    @State var savedList: [[String:String]] = []
    var body: some View {
        ZStack {
            VStack {
                Text("收藏")
                    .font(Font.title)
                List(savedList, id: \.self) { item in
                    if let routeName = item["routeName"],
                       let stopID = item["stopID"],
                       let stopName = item["stopName"] {
                        HStack {
                            Text(routeName)
                            Text(stopName)
                            Spacer()
                        }
                            .onTapGesture {
                                onClickRouteName(routeName: routeName)
                                push.toggle()
                            }
                    }
                    
                    
                    
                }
                
                .navigationTitle("收藏站牌")
                .onAppear {
                    getSavedStop()
                }
            }
            if push {
               // TestView(push: $push)
                RouteSheet(
                    push: $push,
                    location: $viewModel.location,
                    title: viewModel.clickedRouteName,
                    arrivalTimes: $viewModel.sortedArrivalTimesForRouteName,
                    stops: $viewModel.sortedStopsForRouteName
                )
            }
        }
    }
    
    func getSavedStop() {

        let userdefault = UserDefaults.standard
        let obj = userdefault.object(forKey: "favorite")
        let list = obj as? [[String: String]]

        if let existingSavedObj = userdefault.object(forKey: "favorite"),
            let existingList = existingSavedObj as? [[String: String]]{
            print("getSavedStop \(existingList)")
            savedList = existingList
        }
    }
    func onClickRouteName(routeName: String) {
        print("onClickRouteName \(routeName)")
        viewModel.clickedRouteName = routeName
        Task {
            await viewModel.fetchArrivalTimeForRouteNameAsync(routeName: routeName)
            await viewModel.fetchStopsAsync(routeName: routeName)
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
