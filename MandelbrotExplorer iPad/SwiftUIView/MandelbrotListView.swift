//
//  MandelbrotListView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 8/13/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import SwiftUI
import UIKit

struct MandelbrotListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: MandelbrotExplorerViewModel
    
    @FetchRequest(entity: MandelbrotEntity.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \MandelbrotEntity.created, ascending: false)]) private var entities: FetchedResults<MandelbrotEntity>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(entities, id: \.created) { entity in
                    if let _ = entity.created {
                        NavigationLink(destination: MandelbrotDetailView(entity: entity)) {
                            itemView(entity: entity)
                        }
                    } else {
                        Text("N/A")
                    }
                }
            }
        }
    }
    
    private func itemView(entity: MandelbrotEntity) -> some View {
        HStack {
            if let data = entity.image, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
            
            Text(entity.description)
        }
    }
}

struct MandelbrotListView_Previews: PreviewProvider {
    static var previews: some View {
        MandelbrotListView()
    }
}
