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
            
            image
                .frame(width: length, height: length)
                .onAppear {
                    viewModel.generateMandelbrotSet(calculationSize: length)
                }
                .onChange(of: length) { _ in
                    viewModel.generateMandelbrotSet(calculationSize: length)
                }
                .onChange(of: viewModel.mandelbrotRect) { newValue in
                    viewModel.generateMandelbrotSet(calculationSize: length)
                }
        }
    }
    
    @ViewBuilder
    private var image: some View {
        if let uiImage = viewModel.mandelbrotImage {
            Image(uiImage: uiImage)
        } else {
            Rectangle()
        }
    }
}
