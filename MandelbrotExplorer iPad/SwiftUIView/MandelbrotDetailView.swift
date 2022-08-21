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
    
    var body: some View {
        ZStack {
            VStack {
                Text("\(entity.maxImaginary)")
                
                HStack {
                    Text("\(entity.minReal)")
                        .rotationEffect(Angle(degrees: -90.0))
                    
                    if let data = entity.image, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    Text("\(entity.maxReal)")
                        .rotationEffect(Angle(degrees: -90.0))
                }
                
                Text("\(entity.minImaginary)")
                
                Spacer()
            }
            
            VStack(alignment: .trailing) {
                Spacer()
                
                HStack {
                    Spacer()
                    Text("max iteration: \(entity.maxIter)")
                }
                
                HStack {
                    Spacer()
                    
                    if let created = entity.created {
                        Text("created on ") + Text(created, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    } else {
                        Text("")
                    }
                }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    MandelbrotExplorerView(defaultEntity: entity)
                } label: {
                    Label("Explore", systemImage: "magnifyingglass")
                }

            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }
    
}

