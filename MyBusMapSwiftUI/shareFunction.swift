//
//  shareFuncction.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/5/4.
//

import Foundation



func onDrag(yTranslation: CGFloat, frameH: Double, maxViewH: Double) -> Double {
    if yTranslation > 0 {
        
        let newframeH=frameH-Double(yTranslation)
        if newframeH>50{
            return newframeH
        }
        
    }
    if yTranslation < 0 {
        
        if frameH<maxViewH{
            return frameH-Double(yTranslation)
        }
        
    }
    return frameH
}
