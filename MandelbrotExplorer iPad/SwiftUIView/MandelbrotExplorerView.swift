//
//  MandelbrotExplorerView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 8/17/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import SwiftUI

struct MandelbrotExplorerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: MandelbrotExplorerViewModel
    
    let defaultEntity: MandelbrotEntity
    
    var body: some View {
        GeometryReader { geometry in
            let bodyLength = geometry.size.width < geometry.size.height ? 0.45 * geometry.size.width : 0.45 * geometry.size.height
            
            VStack {
                Spacer()
                
                HStack(alignment: .top) {
                    Spacer()
                    
                    VStack {
                        ZoomedMandelbrotView(uiImage: $viewModel.mandelbrotImage)
                            .scaledToFit()
                            .onChange(of: viewModel.mandelbrotRect) { _ in
                                viewModel.generateMandelbrotSet()
                            }
                            //.frame(width: bodyLength, height: bodyLength)
                            
                        Divider()
                        
                        MandelbrotInfoView(minReal: viewModel.mandelbrotRect.minReal,
                                           maxReal: viewModel.mandelbrotRect.maxReal,
                                           minImaginary: viewModel.mandelbrotRect.minImaginary,
                                           maxImaginary: viewModel.mandelbrotRect.maxImaginary)
                        
                        Text("Scale: \(viewModel.scale)")
                        
                        optionView
                    }
                    
                    Spacer()
                    
                    VStack {
                        if let data = defaultEntity.image, let uiImage = UIImage(data: data) {
                            MandelbrotView(uiImage: uiImage,
                                           location: CGPoint(x: 0.5 * bodyLength, y: 0.5 * bodyLength),
                                           length: bodyLength / viewModel.scale)
                            .scaledToFit()
                                //.frame(width: bodyLength, height: bodyLength)
                        }
                        
                        Divider()
                        
                        MandelbrotInfoView(minReal: defaultEntity.minReal,
                                           maxReal: defaultEntity.maxReal,
                                           minImaginary: defaultEntity.minImaginary,
                                           maxImaginary: defaultEntity.maxImaginary)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .frame(alignment:. center)
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.createMandelbrotEntity(viewContext: viewContext)
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Label("Reset", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
    
    private var optionView: some View {
        HStack {
            Spacer()
            
            Text("Color Map")
                .font(.callout)
            Picker("Color Map", selection: $viewModel.colorMap) {
                ForEach(MandelbrotExplorerColorMap.allCases) { colorMap in
                    Text(colorMap.rawValue)
                        .font(.title3)
                }
            }
            
            Spacer()
            
            Text("Maximum Iterations")
                .font(.callout)
            Picker("Maximum Iterations", selection: $viewModel.maxIter) {
                ForEach(MaxIter.allCases) { maxIter in
                    Text("\(maxIter.rawValue)")
                        .font(.title3)
                }
            }
            
            Spacer()
        }
    }
    
    private var infoView: some View {
        VStack {
            HStack {
                Spacer()
                
                MandelbrotInfoView(minReal: viewModel.mandelbrotRect.minReal,
                                   maxReal: viewModel.mandelbrotRect.maxReal,
                                   minImaginary: viewModel.mandelbrotRect.minImaginary,
                                   maxImaginary: viewModel.mandelbrotRect.maxImaginary)
                
                Spacer()
                
                MandelbrotInfoView(minReal: defaultEntity.minReal,
                                   maxReal: defaultEntity.maxReal,
                                   minImaginary: defaultEntity.minImaginary,
                                   maxImaginary: defaultEntity.maxImaginary)
                
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("Scale: \(viewModel.scale)")
                Spacer()
            }
        }
    }
}

