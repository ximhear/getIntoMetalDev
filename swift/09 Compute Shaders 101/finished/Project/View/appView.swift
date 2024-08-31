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
    
    var body: some View {
        VStack{
            
            Text("Ray Tracing!")
        
            GeometryReader { geometry in
                ContentView()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

/*
 ...but must be manually forwarded if a preview is requested
 */
struct appView_Previews: PreviewProvider {
    static var previews: some View {
        appView()
    }
}
