//
//  ListView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/31/22.
//

import SwiftUI
import RealmSwift

struct FavStationsView: View {
    @EnvironmentObject var authManager: AuthManager
//    @ObservedObject var viewModel: MapViewModel
    @StateObject var favStationsViewModel=FavStationsViewModel()
    @State var push: Bool = false
    @State var showAlert: Bool = false
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView(content: {
            
            ZStack {
                VStack {
                    Text("路線收藏")
                        .font(Font.headline)
                        .padding()
                    
                    if !authManager.isLogin {
                        List {
                            ForEach(favStationsViewModel.realmFavList) { item in
//                                NavigationLink(destination: RouteSheet(
//                                    mapViewModel: viewModel,
//                                    viewModel: RouteSheetViewModel(routeName: item.name, location: viewModel.location),
//                                    push: $push,
//                                    location: $viewModel.location,
//                                    title: viewModel.clickedRouteName,
//                                    stops: $viewModel.sortedStopsForRouteName)
//                                 ){
//                                    HStack {
//                                        Text(item.name)
//                                        Spacer()
//                                        Image(systemName: "heart.fill")
//                                    }
//                                }
                                Button(action: {
                                    print("click")
                                    selectedTab = 0
                                }, label: {
                                    HStack {
                                        Text(item.name)
                                        Spacer()
                                        Image(systemName: "heart.fill")
                                    }
                                })
                                
                            }
                            .onDelete(perform: onDeleteLocal(with:))
  
                        }
                    } else {
                        List {
                            
                            ForEach(favStationsViewModel.favoriteList) { item in
//                                NavigationLink(destination: RouteSheet(
//                                    mapViewModel: viewModel,
//                                    viewModel: RouteSheetViewModel(routeName: item.name ?? "", location: viewModel.location),
//                                    push: $push,
//                                    location: $viewModel.location,
//                                    title: viewModel.clickedRouteName,
//                                    stops: $viewModel.sortedStopsForRouteName)
//                                ){
//                                    HStack {
//                                        Text(item.name ?? "")
//                                        
//                                        Spacer()
//                                        Image(systemName: "heart.fill")
//                                    }
//                                }
                                Button(action: {
                                    print("click")
                                    selectedTab = 0
                                }, label: {
                                    HStack {
                                        Text(item.name ?? "")
                                        Spacer()
                                        Image(systemName: "heart.fill")
                                    }
                                })
                            }.onDelete(perform: onDeleteRemote)
                        }
                        .onAppear {
                            favStationsViewModel.getRemoteData()
                        }
                    }
                    
                }
            }
        })
    }
    func onDeleteRemote(with offset: IndexSet) {
        let index = offset[offset.startIndex]
        let favorite = favStationsViewModel.favoriteList[index]
        FirebaseManager.shared.removeFromRemote(favorite: favorite)
    }
    func onDeleteLocal(with offset: IndexSet) {
        let index = offset[offset.startIndex]
        
        RealmManager.shared.deleteFromDB(objectToDelete: favStationsViewModel.realmFavList[index])
    }

}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        FavStationsView(
            favStationsViewModel: FavStationsViewModel(),
            selectedTab: .constant(0)
        )
    }
}
