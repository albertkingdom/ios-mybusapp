//
//  View+Extension.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/19.
//

import SwiftUI

extension View {
    func bottomSheetStyle() -> some View {
        padding(.top)
            .background(Color.white)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .ignoresSafeArea(edges: [.bottom])
        //                .compositingGroup()
            .shadow(color: .gray, radius: 1, x: 0, y: -1)
            .mask(Rectangle()
                .padding(.top, -20))
    }
    func onDrag(yTranslation: CGFloat, frameH: Double, maxViewH: Double) -> Double {
        if yTranslation > 0 {
            let newframeH=frameH-Double(yTranslation)
            if newframeH > 110 { // 最低高度
                return newframeH
            }
        }
        if yTranslation < 0 {
            if frameH < maxViewH {
                return frameH-Double(yTranslation)
            }
        }
        return frameH
    }
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
