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
       
            
                Button(action: {
                    showLocationSearch = true
                }, label: {
//
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

                })
                .padding([.horizontal], 10)
                .frame(height: 50)
                .background(Color.white)
    }
}

#Preview {
    SearchBarView(query: .constant("Tap to Search"), showLocationSearch: .constant(true))
}
