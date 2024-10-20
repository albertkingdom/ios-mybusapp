//
//  CurrentLocationButton.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/20.
//

import SwiftUI

struct CurrentLocationButton: View {
    var onTapButton: () -> Void
    var body: some View {
        Button(action: {
            onTapButton()
        }){
            Image(systemName: "location.fill")
                .frame(width: 50, height: 50)
                .background(Color.white)
                .border(.clear)
                .shadow(radius: 5)
        }
    }
}

#Preview {
    CurrentLocationButton(onTapButton: {})
}
