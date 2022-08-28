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
                    location = validate(location: newLocation, in: geometry.size, given: length)
                }
                .onEnded { _ in
                    viewModel.needToRefresh.toggle()
                }
                
            let magnificationGesture = MagnificationGesture(minimumScaleDelta: 0.001)
                .updating($magnifyBy) { currentState, gestureState, transaction in
                    gestureState = gestureState ?? 1.0
                }
                .onChanged { value in
                    let newLength = length + 5.0 * (value - 1.0)
                    length = validate(length: newLength, in: geometry.size, given: location)
                }
                .onEnded { _ in
                    viewModel.needToRefresh.toggle()
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
            .onChange(of: geometry.size) { _ in
                location = validate(location: location, in: geometry.size, given: length)
                viewModel.needToRefresh.toggle()
            }
            .onChange(of: viewModel.refresh) { _ in
                viewModel.updateRange(origin: location, length: length, originalLength: bodyLength)
            }
        }
    }
    
    private var rect: some View {
        return Rectangle()
            .strokeBorder(Color.white, lineWidth: 2.0)
            .frame(width: length, height: length)
    }
    
    private func validate(location: CGPoint, in frame: CGSize, given length: CGFloat) -> CGPoint {
        var newLocation = location
        
        if newLocation.x - 0.5 * length < 0.0 {
            newLocation.x = 0.5 * length
        }
        
        if newLocation.x + 0.5 * length > frame.width {
            newLocation.x = frame.width - 0.5 * length
        }
        
        if newLocation.y - 0.5 * length < 0.0 {
            newLocation.y = 0.5 * length
        }
        
        if newLocation.y + 0.5 * length > frame.height {
            newLocation.y = frame.height - 0.5 * length
        }
        
        return newLocation
    }
    
    private func validate(length: CGFloat, in frame: CGSize, given location: CGPoint) -> CGFloat {
        var newLength = length
        
        if newLength < 10.0 {
            newLength = 10.0
        } else {
            if location.x - 0.5 * length < 0.0 {
                newLength = 2.0 * location.x
            }
            
            if location.x + 0.5 * length > frame.width {
                newLength = 2.0 * (frame.width - location.x)
            }
            
            if location.y - 0.5 * length < 0.0 {
                newLength = 2.0 * location.y
            }
            
            if location.y + 0.5 * length > frame.height {
                newLength = 2.0 * (frame.height - location.y)
            }
        }
        
        return newLength
    }
    
}

