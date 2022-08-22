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
                HStack {
                    if let data = defaultEntity.image, let uiImage = UIImage(data: data) {
                        Spacer()
                        ZoomedMandelbrotView()
                            .frame(width: bodyLength, height: bodyLength)
                        Spacer()
                        MandelbrotView(entity: defaultEntity, uiImage: uiImage, location: CGPoint(x: 0.5 * bodyLength, y: 0.5 * bodyLength), length: bodyLength / viewModel.scale)
                            .frame(width: bodyLength, height: bodyLength)
                        Spacer()
                    }
                }
                
                infoView()
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Color Map")
                            .font(.callout)
                        Picker("Color Map", selection: $viewModel.colorMap) {
                            ForEach(MandelbrotExplorerColorMap.allCases) { colorMap in
                                Text(colorMap.rawValue)
                                    .font(.title3)
                            }
                        }
                        .onChange(of: viewModel.colorMap) { _ in
                            viewModel.generateMandelbrotSet(calculationSize: bodyLength)
                        }
                    }
                    
                    HStack {
                        Text("Maximum Iteration")
                            .font(.callout)
                        Picker("Maximum Iteration", selection: $viewModel.maxIter) {
                            ForEach(MaxIter.allCases) { maxIter in
                                Text("\(maxIter.rawValue)")
                                    .font(.title3)
                            }
                        }
                        .onChange(of: viewModel.maxIter) { _ in
                            viewModel.generateMandelbrotSet(calculationSize: bodyLength)
                        }
                    }
                    
                }

                Spacer()
            }
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
    
    private func infoView() -> some View {
        VStack {
            HStack {
                Spacer()
                Text("Range")
                Spacer()
                Text("Min")
                Spacer()
                Text("Max")
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("Real")
                Spacer()
                Text("\(viewModel.mandelbrotRect.minReal)")
                Spacer()
                Text("\(viewModel.mandelbrotRect.maxReal)")
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("Imaginary")
                Spacer()
                Text("\(viewModel.mandelbrotRect.minImaginary)")
                Spacer()
                Text("\(viewModel.mandelbrotRect.maxImaginary)")
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("Scale")
                Spacer()
                Text("\(viewModel.scale)")
                Spacer()
            }
        }
    }
    
}

