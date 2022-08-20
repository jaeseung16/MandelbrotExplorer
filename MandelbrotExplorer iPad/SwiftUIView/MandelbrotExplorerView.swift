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
    
    var body: some View {
        ZStack {
            if let data = defaultEntity.image, let uiImage = UIImage(data: data) {
               MandelbrotView(uiImage: uiImage)
            }
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

