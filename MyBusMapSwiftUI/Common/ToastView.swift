//
//  ToastView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 2025/11/9.
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
            .transition(.opacity)
            .zIndex(1)
    }
}

#Preview {
    ToastView(message: "這是一個錯誤訊息")
}
