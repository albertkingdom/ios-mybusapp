//
//  Tabs.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/28/22.
//

import SwiftUI
import os

let logger = Logger(subsystem: "com.a2006mike.MyBusMapSwiftUI", category: "yourcategory")
struct Tab {
    var icon: Image?
    var title: String
}
struct Tabs: View {
    var fixed = true
    var tabs: [Tab]
    var geoWidth: CGFloat
    var directionKeys: [Direction] // New property
    @Binding var selectedTab: Direction // Changed type
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(Array(tabs.enumerated()), id: \.element.title) { (index, tab) in
                            Button(action: {
                                withAnimation {
                                    selectedTab = directionKeys[index]
                                }
                            }, label: {
                                VStack(spacing: 0) {
                                    HStack {
                                        Text(tab.title)
                                            .font(Font.system(size: 18, weight: .semibold))
                                            .foregroundColor(Color.primary)
                                            .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 15))
                                    }
                                    .frame(width: fixed ? (geoWidth / CGFloat(tabs.count)) : .none, height: 40)
                                    // Bar Indicator
                                    Rectangle().fill(selectedTab == directionKeys[index] ? Color.blue : Color.clear)
                                        .frame(height: 5)
                                }
                            })
                                .accentColor(Color.white)
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .onChange(of: selectedTab) { target in
                        withAnimation {
                            // Find the index of the selected Direction and scroll to it
                            if let index = directionKeys.firstIndex(of: target) {
                                proxy.scrollTo(tabs[index].title) // Scroll to the title as ID
                            }
                        }
                    }
                }
            }
        }
//        .frame(height: 55)
        .onAppear(perform: {
//            UIScrollView.appearance().backgroundColor = UIColor(#colorLiteral(red: 0.6196078431, green: 0.1098039216, blue: 0.2509803922, alpha: 1))
            UIScrollView.appearance().bounces = fixed ? false : true
        })
        .onDisappear(perform: {
            UIScrollView.appearance().bounces = true
        })
    }
}
#Preview {
    let dummyDirections: [Direction] = [.outbound, .inbound]
    
    return Tabs(fixed: true,
         tabs: [.init(icon: Image(systemName: "star.fill"), title: "Tab 1"),
                .init(icon: Image(systemName: "star.fill"), title: "Tab 2")],
         geoWidth: 375,
         directionKeys: dummyDirections,
         selectedTab: .constant(.outbound))
}
