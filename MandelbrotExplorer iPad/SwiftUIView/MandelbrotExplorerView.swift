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
                
                Spacer()
                
                Button {
                    viewModel.generateMandelbrotSet(calculationSize: bodyLength)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise.circle")
                }

                infoView()
                
                Spacer()
                
                HStack {
                    Picker("Color Map", selection: $viewModel.colorMap) {
                        ForEach(MandelbrotExplorerColorMap.allCases) { colorMap in
                            Text(colorMap.rawValue)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Picker("Maximum Iteration", selection: $viewModel.maxIter) {
                        ForEach(MaxIter.allCases) { maxIter in
                            Text("\(maxIter.rawValue)")
                        }
                    }
                    .pickerStyle(.wheel)
                    
                }
                
                Spacer()
                
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Save")
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

