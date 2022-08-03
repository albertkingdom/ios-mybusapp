//
//  TestView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/31/22.
//

import SwiftUI

struct TestView: View {
    @Binding var push: Bool
    var body: some View {
        VStack {
            Text("TestView")
            //.frame(maxWidth: .infinity, maxHeight: .infinity)
            //.ignoresSafeArea( edges: [.top])
                //.background(Color.yellow)
            Spacer()
            Button("close") {
                push.toggle()
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: [.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .background(Color.yellow)
        //.ignoresSafeArea()
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView(push: .constant(false))
    }
}
