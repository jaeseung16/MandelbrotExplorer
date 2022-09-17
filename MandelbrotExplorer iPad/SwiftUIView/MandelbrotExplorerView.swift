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
    
    @State private var showAlert = false
    @State private var showProgress = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                HStack(alignment: .top) {
                    Spacer()
                    
                    VStack {
                        ZoomedMandelbrotView()
                            .scaledToFit()
                            .onChange(of: viewModel.mandelbrotRect) { _ in
                                viewModel.generateMandelbrotImage()
                            }
                            .overlay {
                                ProgressView("Please wait...")
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .opacity(viewModel.calculating ? 1 : 0)
                            }
                            
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
                                           scaledLocation: CGPoint(x: 0.5, y: 0.5),
                                           scaledLength: 1.0 / viewModel.scale)
                            .scaledToFit()
                        }
                        
                        Divider()
                        
                        MandelbrotInfoView(minReal: defaultEntity.minReal,
                                           maxReal: defaultEntity.maxReal,
                                           minImaginary: defaultEntity.minImaginary,
                                           maxImaginary: defaultEntity.maxImaginary)
                        
                    }
                    
                    Spacer()
                }
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Label("Mandelbrot Set Generator", systemImage: "cpu")
                        
                        Picker(selection: $viewModel.generatingDevice) {
                            Text("CPU").tag(MandelbrotSetGeneratingDevice.cpu)
                            Text("GPU").tag(MandelbrotSetGeneratingDevice.gpu)
                        } label: {
                            Label("Mandelbrot Set Generator", systemImage: "cpu")
                        }
                        .onChange(of: viewModel.generatingDevice) { _ in
                            viewModel.generateMandelbrotImage()
                        }
                        
                        Spacer()
                    }
                    
                    if viewModel.isTooSmallToUseGPU() {
                        Text("CPU Recommended")
                    } else {
                        EmptyView()
                    }
                }
                
                Spacer()
            }
            .disabled(viewModel.calculating)
            .alert("Saved", isPresented: $showAlert, actions: {
                Button("Dismiss") {
                    //
                }
            })
            .frame(alignment:. center)
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.createMandelbrotEntity(viewContext: viewContext) { success in
                            if success {
                                showAlert.toggle()
                            }
                        }
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.prepareExploring()
                    } label: {
                        Text("Reset")
                    }
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

