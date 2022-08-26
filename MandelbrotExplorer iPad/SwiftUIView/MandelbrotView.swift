//
//  MandelbrotView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 8/17/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import SwiftUI

struct MandelbrotView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: MandelbrotExplorerViewModel
    
    let uiImage: UIImage
    @State var location: CGPoint
    @State var length: CGFloat
    
    @GestureState private var startLocation: CGPoint? = nil
    @GestureState var magnifyBy: CGFloat?
   
    var body: some View {
        GeometryReader { geometry in
            let bodyLength = geometry.size.width < geometry.size.height ? geometry.size.width : geometry.size.height
            
            let dragGesture = DragGesture()
                .updating($startLocation) { value, startLocation, transaction in
                    startLocation = startLocation ?? location
                }
                .onChanged { value in
                    var newLocation = startLocation ?? location
                    newLocation.x += value.translation.width
                    newLocation.y += value.translation.height
                    
                    if newLocation.x - 0.5 * length < 0.0 {
                        newLocation.x = 0.5 * length
                    }
                    
                    if newLocation.x + 0.5 * length > geometry.size.width {
                        newLocation.x = geometry.size.width - 0.5 * length
                    }
                    
                    if newLocation.y - 0.5 * length < 0.0 {
                        newLocation.y = 0.5 * length
                    }
                    
                    if newLocation.y + 0.5 * length > geometry.size.height {
                        newLocation.y = geometry.size.height - 0.5 * length
                    }

                    location = newLocation
                }
                .onEnded { _ in
                    viewModel.updateRange(origin: location, length: length, originalLength: bodyLength)
                }
                
            let magnificationGesture = MagnificationGesture(minimumScaleDelta: 0.001)
                .updating($magnifyBy) { currentState, gestureState, transaction in
                    gestureState = gestureState ?? 1.0
                }
                .onChanged { value in
                    let newLength = length + 5.0 * (value - 1.0)
                    if newLength < 10.0 {
                        length = 10.0
                    } else {
                        length = newLength
                    }
                    
                    if location.x - 0.5 * length < 0.0 {
                        length = 2.0 * location.x
                    }
                    
                    if location.x + 0.5 * length > geometry.size.width {
                        length = 2.0 * (geometry.size.width - location.x)
                    }
                    
                    if location.y - 0.5 * length < 0.0 {
                        length = 2.0 * location.y
                    }
                    
                    if location.y + 0.5 * length > geometry.size.height {
                        length = 2.0 * (geometry.size.height - location.y)
                    }
                }
                .onEnded { _ in
                    viewModel.updateRange(origin: location, length: length, originalLength: bodyLength)
                }
            
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                
                rect
                    .position(location)
                    
            }
            .gesture(dragGesture)
            .simultaneousGesture(magnificationGesture)
            .frame(width: bodyLength, height: bodyLength)
            .onChange(of: viewModel.colorMap) { _ in
                viewModel.generateMandelbrotSet()
            }
            .onChange(of: viewModel.maxIter) { _ in
                viewModel.generateMandelbrotSet()
            }
        }
    }
    
    private var rect: some View {
        return Rectangle()
            .strokeBorder(Color.white, lineWidth: 2.0)
            .frame(width: length, height: length)
    }
    
    
}

