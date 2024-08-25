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
    
    @EnvironmentObject var gameScene: GameScene
    
    var body: some View {
        GeometryReader(content: { geometry in
            ContentView()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            gameScene.spinPlayer(offset: gesture.translation)
                        }
                )
        })
        .ignoresSafeArea()
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
