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
    
    let entity: MandelbrotEntity
    let minReal: Double
    let maxReal: Double
    let minImaginary: Double
    let maxImaginary: Double
    let uiImage: UIImage
    let maxIter: Int
    let created: Date
    
    @State private var presentShareSheet = false
    
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
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let shareView = ShareView(minReal: minReal,
                                              maxReal: maxReal,
                                              minImaginary: minImaginary,
                                              maxImaginary: maxImaginary,
                                              maxIter: maxIter,
                                              created: created,
                                              uiImage: uiImage)
                    viewModel.generateImage(from: shareView)
                    presentShareSheet.toggle()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            viewModel.defaultMandelbrotEntity = entity
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
                
                Text("\(maxReal)")
                    .rotationEffect(Angle(degrees: -90.0))
            }
            
            Text("\(minImaginary)")
        }
    }
    
    private var summaryView: some View {
        HStack {
            Spacer()
            Text("max iteration: \(maxIter)\ncreated on ") + Text(created, format: Date.FormatStyle(date: .numeric, time: .omitted))
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
