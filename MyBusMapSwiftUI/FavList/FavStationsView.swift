//
//  ListView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/31/22.
//

import ComposableArchitecture
import RealmSwift
import SwiftUI

@Reducer
struct FavStations {
    @ObservableState
    struct State: Equatable {
        var displayList: [FavoriteDisplayItem] = []
        var realmFavList: [FavoriteRealm] = []
        var favoriteList: [Favorite] = []
        var isLoggedIn: Bool = false
    }

    enum Action {
        case deleteRemoteData(indexSet: IndexSet)
        case deleteLocalData(indexSet: IndexSet)
        case getRemoteData(email: String)
        case readLocalData
        case setFavoriteList(favoriteList: [Favorite])
        case setRealmFavList(realmFavList: [FavoriteRealm])
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.firebaseClient) var firebaseClient
    @Dependency(\.realmClient) var realmClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .deleteRemoteData(let indexSet):
                guard let index = indexSet.first else { return .none }
                let favorite = state.favoriteList[index]
                state.favoriteList.remove(at: index)
                state.displayList = updateDisplayList(state: state)

                return .run { _ in
                    await firebaseClient.removeFromRemote(favorite)

                }

            case .deleteLocalData(let indexSet):
                guard let index = indexSet.first else { return .none }

                let favorite = state.realmFavList[index]
                state.realmFavList.remove(at: index)
                state.displayList = updateDisplayList(state: state)

                return .run { _ in
                    await realmClient.deleteFromDB(favorite)
                }
            case .getRemoteData(let email):

                return .run { send in
                    let favorites = await firebaseClient.getRemoteData(email)
                    await send(.setFavoriteList(favoriteList: favorites))
                }
            case .readLocalData:
                return .run { send in
                    let favorites = await realmClient.readAllFromDB()
                    await send(.setRealmFavList(realmFavList: favorites))
                }

            case .setFavoriteList(let favoriteList):
                state.favoriteList = favoriteList
                state.displayList = updateDisplayList(state: state)
                return .none
            case .setRealmFavList(let realmFavList):
                state.realmFavList = realmFavList
                state.displayList = updateDisplayList(state: state)
                return .none
            }
        }
    }

    private func updateDisplayList(state: State) -> [FavoriteDisplayItem] {
        if state.isLoggedIn {
            return state.favoriteList.map {
                FavoriteDisplayItem(name: $0.name ?? "", isRemote: true)
            }
        } else {
            return state.realmFavList.map {
                FavoriteDisplayItem(name: $0.name, isRemote: false)
            }
        }
    }
}

struct FavStationsView: View {
    let store: StoreOf<FavStations>
    @EnvironmentObject var authManager: AuthManager
    //    @EnvironmentObject var firebaseManager: FirebaseManager
    //    @StateObject var favStationsViewModel: FavStationsViewModel
    @State var push: Bool = false
    @State var showAlert: Bool = false
    @Binding var selectedTab: Int

    var body: some View {
            
            NavigationView(
                content: {
                    
                    ZStack {
                        VStack {
                            Text("路線收藏")
                                .font(Font.headline)
                                .padding()
                            
                            List {
                                ForEach(store.displayList) { item in
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
                                        store.send(
                                            .deleteRemoteData(indexSet: indexSet))
                                    } else {
                                        store.send(
                                            .deleteLocalData(indexSet: indexSet))
                                    }
                                }
                                
                            }
                            .onAppear {
                                if authManager.isLogin {
                                    
                                    store.send(
                                        .getRemoteData(email: authManager.email))
                                } else {
                                    store.send(.readLocalData)
                                }
                            }
                        }
                    }
                })
        }
    
}

#Preview {

}
