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
    let minReal: Double
    let maxReal: Double
    let minImaginary: Double
    let maxImaginary: Double
    @State var uiImage: UIImage
    @State var maxIter: MaxIter
    @State var colorMap: MandelbrotExplorerColorMap
    @State var generator: MandelbrotSetGeneratingDevice
    let created: Date
    
    @State private var presentShareSheet = false
    @State private var modified = false
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            NavigationLink {
                MandelbrotExplorerView(defaultEntity: entity)
            } label: {
                Label("Explore", systemImage: "magnifyingglass")
            }
            
            Spacer()
            
            detailView
            
            summaryView
            
            Spacer()
        }
        .disabled(viewModel.calculating)
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
                    viewModel.update(entity, viewContext: viewContext) { success in
                        print("update success=\(success)")
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
            if viewModel.defaultMandelbrotEntity == nil || viewModel.defaultMandelbrotEntity != entity {
                viewModel.defaultMandelbrotEntity = entity
            }
            viewModel.prepareExploring()
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
                            .opacity(viewModel.calculating ? 1 : 0)
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
                        viewModel.colorMap = colorMap
                        viewModel.maxIter = maxIter
                        viewModel.generatingDevice = generator
                        viewModel.generateDefaultMandelbrotImage()
                        modified = true
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
                        viewModel.colorMap = colorMap
                        viewModel.maxIter = maxIter
                        viewModel.generatingDevice = generator
                        viewModel.generateDefaultMandelbrotImage()
                        modified = true
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
                        viewModel.colorMap = colorMap
                        viewModel.maxIter = maxIter
                        viewModel.generatingDevice = generator
                        viewModel.generateDefaultMandelbrotImage()
                        modified = true
                    }
                }
                
                
                Text("created on ").font(.caption) + Text(created, format: Date.FormatStyle(date: .numeric, time: .omitted)).font(.caption)
            }
        }
    }
    
    private var shareView: some View {
        VStack {
            detailView
            summaryView
        }
        .frame(width: 500, height: 500)
    }
    
    private func generateImage() -> UIImage {
        let controller = UIHostingController(rootView: shareView)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let renderedImage = renderer.image { ctx in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        return renderedImage
    }
    
}

extension View {
    func snapshot() -> UIImage {
        var uiImage = UIImage(systemName: "exclamationmark.triangle.fill")!
        
        let controller = UIHostingController(rootView: self)
        
        if let view = controller.view {
            let contentSize = controller.view.intrinsicContentSize
            view.bounds = CGRect(origin: .zero, size: contentSize)
            view.backgroundColor = .clear
            
            let renderer = UIGraphicsImageRenderer(size: contentSize)
            
            uiImage = renderer.image { _ in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
        }
        
        return uiImage
    }
}
