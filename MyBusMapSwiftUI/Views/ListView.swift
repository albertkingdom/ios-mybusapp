//
//  ListView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/31/22.
//

import SwiftUI
import RealmSwift

struct ListView: View {
    @ObservedObject var viewModel = MapViewModel.shared
    @State var push: Bool = false
    @State var localSavedFavList: [Favorite] = []
    @State var showAlert: Bool = false
    @State var realmFavList: Results<FavoriteRealm> = RealmManager.shared.readAllFromDB()

    var body: some View {
        ZStack {
            VStack {
                Text("路線收藏")
                    .font(Font.headline)
                    .padding()
                  
                if !viewModel.isLogin {
                    
                    List {
                        ForEach(realmFavList) { item in
                            HStack {
                                HStack {
                                    Text(item.name)
                                    
                                    Spacer()
                                    Image(systemName: "heart.fill")
                                }
                            }
                            .onTapGesture {
                                onClickRouteName(routeName: item.name)
                                push.toggle()
                            }
                        }.onDelete(perform: onDeleteLocal(with:))
                    }
                    .onAppear {
                    }
                    
                } else {
                    Text("滑動刪除")
                    List {
                        
                        ForEach(viewModel.favoriteList) { item in
                            HStack {
                                HStack {
                                    Text(item.name ?? "")
                                    
                                    Spacer()
                                    Image(systemName: "heart.fill")
                                }
                            }
                            .onTapGesture {
                                onClickRouteName(routeName: item.name ?? "")
                                push.toggle()
                            }
                            
                        }.onDelete(perform: onDeleteRemote)
                    }
                    .onAppear {
                        viewModel.getRemoteData()
                    }
                }
                
            }
            
            if push {
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
    func onDeleteRemote(with offset: IndexSet) {
        let index = offset[offset.startIndex]
        let favorite = viewModel.favoriteList[index]
        FirebaseManager.shared.removeFromRemote(favorite: favorite)
    }
    func onDeleteLocal(with offset: IndexSet) {
        let index = offset[offset.startIndex]
        
        RealmManager.shared.deleteFromDB(objectToDelete: realmFavList[index])
    }

    func onClickRouteName(routeName: String) {
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
