//
//  ListView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/31/22.
//

import RealmSwift
import SwiftUI

struct FavStationsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firebaseManager: FirebaseManager
    @StateObject var favStationsViewModel: FavStationsViewModel
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

                    List {
                        ForEach(favStationsViewModel.displayList) { item in
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
                            Button(
                                action: {
                                    print("click")
                                    selectedTab = 0
                                },
                                label: {
                                    HStack {
                                        Text(item.name)
                                        Spacer()
                                        Image(systemName: "heart.fill")
                                    }
                                }
                            )

                        }
                        .onDelete { indexSet in
                            if authManager.isLogin {
                                favStationsViewModel.deleteRemoteData(
                                    indexSet: indexSet)
                            } else {
                                favStationsViewModel.deleteLocalData(
                                    indexSet: indexSet)
                            }
                        }

                    }
                    .onAppear {
                        if authManager.isLogin {
                            Task {
                                await favStationsViewModel.getRemoteData(
                                    email: authManager.email)
                            }
                        } else {
                            favStationsViewModel.readLocalData()
                        }
                    }
                }
            }
        })
    }
}

#Preview {

}
