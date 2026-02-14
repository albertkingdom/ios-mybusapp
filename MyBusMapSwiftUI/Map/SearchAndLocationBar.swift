//
//  SearchAndLocationBar.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2025/2/23.
//

import SwiftUI

struct SearchAndLocationBar: View {
    @Binding var query: String
    @Binding var showLocationSearch: Bool
    var onCurrentLocationTap: () -> Void

    var body: some View {
        HStack {
            SearchBarView(query: $query, showLocationSearch: $showLocationSearch)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding([.horizontal], 10)
            CurrentLocationButton(onTapButton: onCurrentLocationTap)
        }
        .padding([.horizontal], 20)
        .frame(width: UIScreen.main.bounds.width)
        .position(CGPoint(x: UIScreen.main.bounds.width / 2, y: 40.0))
    }
}

#Preview {
    SearchBarView(query: .constant("Tap"), showLocationSearch: .constant(false))
}
