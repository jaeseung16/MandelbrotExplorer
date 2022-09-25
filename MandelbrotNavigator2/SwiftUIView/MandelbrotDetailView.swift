//
//  MandelbrotDetailView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 8/13/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import SwiftUI
import UIKit

struct MandelbrotDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: MandelbrotExplorerViewModel
    @Environment(\.dismiss) private var dismiss
    
    let entity: MandelbrotEntity
    
    private var minReal: Double {
        entity.minReal
    }
    
    private var maxReal: Double {
        entity.maxReal
    }
    
    private var minImaginary: Double {
        entity.minImaginary
    }
    
    private var maxImaginary: Double {
        entity.maxImaginary
    }
    
    @State var uiImage: UIImage
    @State var maxIter: MaxIter
    @State var colorMap: MandelbrotExplorerColorMap
    @State var generator: MandelbrotSetGeneratingDevice
    let created: Date
    
    @State private var presentShareSheet = false
    @State private var modified = false
    @State private var showAlert = false
    
    @State private var presentExplorerView = false
    @State private var calculating = false
    
    @State private var zoomedMandelbrotImage: UIImage?
    
    var body: some View {
        VStack {
            NavigationLink {
                MandelbrotExplorerView(defaultEntity: entity,
                                       maxIter: MaxIter(rawValue: Int(entity.maxIter)) ?? .twoHundred,
                                       colorMap: MandelbrotExplorerColorMap(rawValue: entity.colorMap ?? "jet") ?? .jet,
                                       generatingDevice: MandelbrotSetGeneratingDevice(rawValue: entity.generator ?? "gpu") ?? .gpu,
                                       zoomedMandelbrotImage: zoomedMandelbrotImage)
            } label: {
                Label("Explore", systemImage: "magnifyingglass")
            }
            
            Spacer()
            
            detailView
            
            summaryView
            
            Spacer()
        }
        .disabled(calculating)
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let shareView = ShareView(minReal: minReal,
                                              maxReal: maxReal,
                                              minImaginary: minImaginary,
                                              maxImaginary: maxImaginary,
                                              maxIter: maxIter.rawValue,
                                              created: created,
                                              uiImage: uiImage)
                    viewModel.generateImage(from: shareView)
                    presentShareSheet.toggle()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let parameters = MandelbrotExplorerParameters(maxIter: maxIter, colorMap: colorMap, generatingDevice: generator)
                    viewModel.update(entity, parameters: parameters, viewContext: viewContext) { success in
                        if success {
                            modified = false
                        } else {
                            showAlert.toggle()
                        }
                    }
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .disabled(!modified)
            }
        }
        .onAppear {
            print("** onAppear")
            if viewModel.defaultMandelbrotEntity == nil || viewModel.defaultMandelbrotEntity != entity {
                viewModel.defaultMandelbrotEntity = entity
            }
            viewModel.prepareExploring() { uiImage in
                zoomedMandelbrotImage = uiImage
            }
        }
        .sheet(isPresented: $presentShareSheet) {
            if let imageToShare = viewModel.imageToShare {
                ShareActivityView(image: imageToShare, applicationActivities: nil)
            } else {
                Button {
                    presentShareSheet.toggle()
                } label: {
                    Text("The image is not ready. Try again.")
                }
            }
        }
        .alert("Failed to update", isPresented: $showAlert, actions: {
            Button("Dismiss") {
                dismiss.callAsFunction()
            }
        })
        
    }
    
    private var detailView: some View {
        VStack {
            Text("\(maxImaginary)")
            
            HStack {
                Text("\(minReal)")
                    .rotationEffect(Angle(degrees: -90.0))
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        ProgressView("Please wait...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .opacity(calculating ? 1 : 0)
                    }
                    .onChange(of: viewModel.defaultMandelbrotImage) { _ in
                        if let mandelbrotImage = viewModel.defaultMandelbrotImage {
                            uiImage = mandelbrotImage
                        }
                    }
                
                Text("\(maxReal)")
                    .rotationEffect(Angle(degrees: -90.0))
            }
            
            Text("\(minImaginary)")
        }
    }
    
    private var summaryView: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack {
                    Text("Color Map")
                        .font(.callout)
                    Picker("Color Map", selection: $colorMap) {
                        ForEach(MandelbrotExplorerColorMap.allCases) { colorMap in
                            Text(colorMap.rawValue)
                                .font(.title3)
                        }
                    }
                    .onChange(of: colorMap) { _ in
                        updateMandelbrotImage()
                    }
                }
                HStack {
                    Text("Maximum Iterations")
                        .font(.callout)
                    Picker("Maximum Iterations", selection: $maxIter) {
                        ForEach(MaxIter.allCases) { maxIter in
                            Text("\(maxIter.rawValue)")
                                .font(.title3)
                        }
                    }
                    .onChange(of: maxIter) { _ in
                        updateMandelbrotImage()
                    }
                }
                
                HStack {
                    Image(systemName: "cpu")
                    Picker(selection: $generator) {
                        Text("CPU").tag(MandelbrotSetGeneratingDevice.cpu)
                        Text("GPU").tag(MandelbrotSetGeneratingDevice.gpu)
                    } label: {
                        Label("Mandelbrot Set Generator", systemImage: "cpu")
                    }
                    .onChange(of: generator) { _ in
                        updateMandelbrotImage()
                    }
                }
                
                Text("created on ").font(.caption) + Text(created, format: Date.FormatStyle(date: .numeric, time: .omitted)).font(.caption)
            }
        }
    }
    
    private func updateMandelbrotImage() -> Void {
        calculating.toggle()
        let parameters = MandelbrotExplorerParameters(maxIter: maxIter, colorMap: colorMap, generatingDevice: generator)
        viewModel.generateDefaultMandelbrotImage(parameters: parameters) {
            calculating.toggle()
        }
        modified = true
    }
    
    private var shareView: some View {
        VStack {
            detailView
            summaryView
        }
        .frame(width: 500, height: 500)
    }
    
}
