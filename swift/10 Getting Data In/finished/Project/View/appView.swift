//
//  appView.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import SwiftUI

/*
 game scene will be automatically forwarded here...
 */
struct appView: View {
    
    @EnvironmentObject var gamescene: GameScene
    
    var body: some View {
        VStack{
            
            Text("Ray Tracing 2!")
        
            GeometryReader { geometry in
                ContentView()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        // leading, trailing, bottom을 ignore safe area로 설정
        .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
    }
}

/*
 ...but must be manually forwarded if a preview is requested
 */
struct appView_Previews: PreviewProvider {
    static var previews: some View {
        appView().environmentObject(GameScene())
    }
}
