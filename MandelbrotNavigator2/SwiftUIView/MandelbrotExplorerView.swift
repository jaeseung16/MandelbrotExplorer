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
    
    @State private var needToUpdate = false
    @State private var reset = false
    @State private var showAlert = false
    
    @State var maxIter: MaxIter
    @State var colorMap: MandelbrotExplorerColorMap
    @State var generatingDevice: MandelbrotSetGeneratingDevice
    
    private var parameters: MandelbrotExplorerParameters {
        return MandelbrotExplorerParameters(maxIter: maxIter,
                                            colorMap: colorMap,
                                            generatingDevice: generatingDevice)
    }
    
    @State var zoomedMandelbrotImage: UIImage?
    @State private var calculating = false
    
    private func calculate() -> Void {
        calculating.toggle()
        viewModel.generateMandelbrotImage(within: viewModel.mandelbrotRect, parameters: parameters) {
            calculating.toggle()
            zoomedMandelbrotImage = viewModel.mandelbrotImage
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                HStack(alignment: .top) {
                    Spacer()
                    
                    VStack {
                        ZoomedMandelbrotView(uiImage: $zoomedMandelbrotImage)
                            .scaledToFit()
                            .overlay {
                                ProgressView("Please wait...")
                                    .foregroundColor(.white)
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .opacity(calculating ? 1 : 0)
                            }
                            .onChange(of: needToUpdate) { newValue in
                                print("*** needToUpdate=\(newValue)")
                                calculate()
                            }
                            
                        Divider()
                        
                        MandelbrotInfoView(minReal: viewModel.mandelbrotRect.minReal,
                                           maxReal: viewModel.mandelbrotRect.maxReal,
                                           minImaginary: viewModel.mandelbrotRect.minImaginary,
                                           maxImaginary: viewModel.mandelbrotRect.maxImaginary)
                        
                        Text("Scale: \(viewModel.scale)")
                        
                        optionView
                            .onChange(of: colorMap) { _ in
                                print("colorMap updated")
                                calculate()
                            }
                            .onChange(of: maxIter) { _ in
                                print("maxIter updated")
                                calculate()
                            }
                    }
                    
                    Spacer()
                    
                    VStack {
                        if let data = defaultEntity.image, let uiImage = UIImage(data: data) {
                            MandelbrotView(uiImage: uiImage,
                                           needToUpdate: $needToUpdate,
                                           reset: $reset,
                                           scaledLocation: CGPoint(x: 0.5, y: 0.5),
                                           scaledLength: 1.0 / viewModel.scale)
                            .scaledToFit()
                        }
                        
                        Divider()
                        
                        MandelbrotInfoView(minReal: defaultEntity.minReal,
                                           maxReal: defaultEntity.maxReal,
                                           minImaginary: defaultEntity.minImaginary,
                                           maxImaginary: defaultEntity.maxImaginary)
                        
                        HStack {
                            Spacer()
                            Text("Color Map: \(defaultEntity.colorMap ?? "jet")")
                            Spacer()
                            Text("Maximum Iterations: \(defaultEntity.maxIter)")
                            Spacer()
                        }
                        
                    }
                    
                    Spacer()
                }
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Label("Mandelbrot Set Generator", systemImage: "cpu")
                        
                        Picker(selection: $generatingDevice) {
                            Text("CPU").tag(MandelbrotSetGeneratingDevice.cpu)
                            Text("GPU").tag(MandelbrotSetGeneratingDevice.gpu)
                        } label: {
                            Label("Mandelbrot Set Generator", systemImage: "cpu")
                        }
                        .onChange(of: generatingDevice) { _ in
                            print("generatingDevice updated")
                            calculate()
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
            .disabled(calculating)
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
                        reset.toggle()
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
            Picker("Color Map", selection: $colorMap) {
                ForEach(MandelbrotExplorerColorMap.allCases) { colorMap in
                    Text(colorMap.rawValue)
                        .font(.title3)
                }
            }
            
            Spacer()
            
            Text("Maximum Iterations")
                .font(.callout)
            Picker("Maximum Iterations", selection: $maxIter) {
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

