//
//  ZoomedMandelbrotView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 8/20/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import SwiftUI

struct ZoomedMandelbrotView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: MandelbrotExplorerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let length = geometry.size.width < geometry.size.height ? geometry.size.width : geometry.size.height
            
            if let uiImage = viewModel.mandelbrotImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: length, height: length)
            } else {
                Button {
                    viewModel.needToRefresh.toggle()
                } label: {
                    Text("Start Exploring")
                }
                .frame(width: length, height: length)
            }
            
        }
    }
    
}
