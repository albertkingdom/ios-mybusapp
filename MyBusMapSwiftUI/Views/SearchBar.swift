//
//  SwiftUIView.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/16.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var query: String
    @Binding var showLocationSearch: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showLocationSearch = true
                }, label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.primary)
                        Text(query)
                            .foregroundColor(Color.gray)
                        Spacer()
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .onTapGesture {
                                query = "Tap to search"
                            }
                    }
                    .padding(.horizontal, 10)
                })
                .frame(width: UIScreen.main.bounds.width - 30, height: 50)
                .background(Color.white)
                Spacer()
            }
            Spacer()
        }
        .padding(.top, 30)
    }
}

#Preview {
    SearchBarView(query: .constant("Tap to Search"), showLocationSearch: .constant(true))
}
