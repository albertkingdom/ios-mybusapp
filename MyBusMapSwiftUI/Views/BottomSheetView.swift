//
//  temp.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/19.
//
import SwiftUI

struct BottomSheetView<Content: View>: View {
    @ViewBuilder let content: Content
    var heightFraction=0.4
    @State var frameH: Double=0.0 // 目前bottom sheet高度
    @State var maxViewH: Double=0.0 // bottom sheet高度上限
    var onClose: () -> Void
    var closeButton: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 20)
            .onTapGesture {
                print("On tap button")
                onClose()
            }
    }
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    ZStack {
                        DragBar()
                        HStack {
                            Spacer()
                            closeButton
                        }
                        .padding(.trailing)
                    }
                    
                    // 這邊插入內容
                }
                
                .frame(height: frameH)
                .bottomSheetStyle()
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.frameH = onDrag(
                                yTranslation: value.translation.height,
                                frameH: self.frameH,
                                maxViewH: self.maxViewH
                            )
                        }
                )
                .onAppear {
                    
//                    viewModel.getRemoteData()
                    self.frameH=geometry.size.height*heightFraction
                    self.maxViewH=geometry.size.height
                    print("初始高度 \(frameH) 最高\(maxViewH)")
                }
                
                
                .onDisappear {
                    print("onDisappear")
                    //                    mapViewModel.stopfetchArrivalTimeRepeatedly()
                }
            }
            
        }
    }
}
