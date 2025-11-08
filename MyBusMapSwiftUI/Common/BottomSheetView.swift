//
//  temp.swift
//  MyBusMapSwiftUI
//
//  Created by yklin on 2024/10/19.
//
import SwiftUI

struct DragBar: View {
    var body: some View {
        Capsule()
            .fill(Color(.systemGray4))
            .frame(width: 40, height: 5)
            .padding(.bottom)
    }
}

struct BottomSheetView<Content: View>: View {
    @ViewBuilder let content: Content
    var heightFraction: Double
    let showCloseButton: Bool
    
    @State var frameH: Double=0.0 // 目前bottom sheet高度
    @State var maxViewH: Double=0.0 // bottom sheet高度上限
    var onClose: () -> Void
    
    init(@ViewBuilder content: () -> Content, heightFraction: Double = 0.4, showCloseButton: Bool = true, onClose: @escaping () -> Void) {
        self.content = content()
        self.heightFraction = heightFraction
        self.showCloseButton = showCloseButton
        self.onClose = onClose
    }
    
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
                            if showCloseButton {
                                closeButton
                            }
                        }
                        .padding(.trailing)
                    }
                    
                    // 這邊插入內容
                    content
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
                    self.frameH=geometry.size.height*heightFraction
                    self.maxViewH=geometry.size.height
                    print("初始高度 \(frameH) 最高\(maxViewH)")
                }
                
                
                .onDisappear {
                    print("onDisappear")
                }
            }
            
        }
    }
}

#Preview {
    BottomSheetView(content: { Text("Hi") }, onClose: {})
}
