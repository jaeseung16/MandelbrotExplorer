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
    
    let defaultEntity: MandelbrotEntity
    
    @State var colorMap: MandelbrotExplorerColorMap = .green
    @State var maxIter: MaxIter = .twoHundred
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    if let data = defaultEntity.image, let uiImage = UIImage(data: data) {
                        Spacer()
                        ZoomedMandelbrotView()
                            .frame(width: 0.45 * geometry.size.width, height: 0.45 * geometry.size.width)
                        Spacer()
                        MandelbrotView(uiImage: uiImage, location: CGPoint(x: 0.25 * geometry.size.width, y: 0.25 * geometry.size.height), length: 0.05 * geometry.size.width)
                            .frame(width: 0.45 * geometry.size.width, height: 0.45 * geometry.size.width)
                        Spacer()
                    }
                }
                
                Spacer()
                
                Button {
                    refresh()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise.circle")
                }

                infoView()
                
                Spacer()
                
                HStack {
                    Picker("Color Map", selection: $colorMap) {
                        ForEach(MandelbrotExplorerColorMap.allCases) { colorMap in
                            Text(colorMap.rawValue)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Picker("Maximum Iteration", selection: $maxIter) {
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
    
    private func refresh() -> Void {
        
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
                Text("Min")
                Spacer()
                Text("Max")
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("Imaginary")
                Spacer()
                Text("Min")
                Spacer()
                Text("Max")
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("Scale")
                Spacer()
            }
        }
    }
    
}

