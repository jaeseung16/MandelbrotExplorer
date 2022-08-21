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
    
    let uiImage: UIImage
    @State var location: CGPoint
    @State var length: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                
                rect
                    .position(location)
                    
            }
            .gesture(dragGesture)
            .simultaneousGesture(magnificationGesure)
           
        }
    }
    
    @GestureState var magnifyBy: CGFloat?
    private var magnificationGesure: some Gesture {
        MagnificationGesture(minimumScaleDelta: 0.001)
            .updating($magnifyBy) { currentState, gestureState, transaction in
                print("currentState=\(currentState)")
                gestureState = gestureState ?? 1.0
            }
            .onChanged { value in
                print("value=\(value)")
                let newLength = length + 5.0 * (value - 1.0)
                if newLength < 10.0 {
                    length = 10.0
                } else if newLength > 200.0 {
                    length = 200.0
                } else {
                    length = newLength
                }
                
            }
    }
    
    @GestureState private var startLocation: CGPoint? = nil
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
            }
            .updating($startLocation) { value, startLocation, transaction in
                startLocation = startLocation ?? location
            }
    }
    
    private var rect: some View {
        return Rectangle()
            .strokeBorder(Color.white, lineWidth: 2.0)
            .frame(width: length, height: length)
            
    }
}

