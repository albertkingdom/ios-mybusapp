//
//  PlateView.swift
//  MyBusMapSwiftUI
//
//  Created by 林煜凱 on 7/30/22.
//

import SwiftUI

struct PlateView: View {
    var estimateTime: Int?
    var body: some View {
        HStack {
            if let time = estimateTime, time < 60 {
                Text("接近中") // should be plate number
                    .frame(width: 50)
                    .background(Color.green)
            }
            
            
            VStack {
                Rectangle()
                    .frame(width: 2)
                    .foregroundColor(Color.gray)
                
                Image(systemName: "circle.fill")
                    .foregroundColor(Color.gray)
                
                Rectangle()
                    .frame(width: 2)
                    .foregroundColor(Color.gray)
            }
        }
        .padding(-5)
    }
}

struct PlateView_Previews: PreviewProvider {
    static var previews: some View {
        PlateView(estimateTime: 30)
    }
}
