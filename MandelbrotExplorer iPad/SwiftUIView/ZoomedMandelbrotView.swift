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
            
            if let image = viewModel.mandelbrotImage {
                Image(uiImage: image)
                    .frame(width: length, height: length)
                    .onAppear {
                        viewModel.generateMandelbrotSet(calculationSize: length)
                    }
                    .onChange(of: length) { _ in
                        viewModel.generateMandelbrotSet(calculationSize: length)
                    }
            } else {
                Rectangle()
                    .strokeBorder(Color.green, lineWidth: 2.0)
                    .frame(width: length, height: length)
                    .onAppear {
                        viewModel.generateMandelbrotSet(calculationSize: length)
                    }
                    .onChange(of: length) { _ in
                        viewModel.generateMandelbrotSet(calculationSize: length)
                    }
            }
                
                
            
                
        }
    }
}
