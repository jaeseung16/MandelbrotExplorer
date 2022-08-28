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
    
    @State private var explore = false
    
    var body: some View {
        ZStack {
            VStack {
                NavigationLink(isActive: $explore) {
                    MandelbrotExplorerView(defaultEntity: entity)
                } label: {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                
                Spacer()
                
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
                
                Spacer()
            }
            
            VStack(alignment: .trailing) {
                Spacer()
                
                HStack {
                    Spacer()
                    Text("max iteration: \(maxIter)")
                }
                
                HStack {
                    Spacer()
                    
                    Text("created on ") + Text(created, format: Date.FormatStyle(date: .numeric, time: .omitted))
                }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        .onAppear {
            viewModel.defaultMandelbrotEntity = entity
        }
    }
    
}

