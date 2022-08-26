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
    
    @FetchRequest(entity: MandelbrotEntity.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \MandelbrotEntity.created, ascending: true)]) private var entities: FetchedResults<MandelbrotEntity>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(entities, id: \.created) { entity in
                    if let created = entity.created, let data = entity.image, let uiImage = UIImage(data: data) {
                        NavigationLink(destination: MandelbrotDetailView(entity: entity,
                                                                         minReal: entity.minReal,
                                                                         maxReal: entity.maxReal,
                                                                         minImaginary: entity.minImaginary,
                                                                         maxImaginary: entity.maxImaginary,
                                                                         uiImage: uiImage,
                                                                         maxIter: Int(entity.maxIter),
                                                                         created: created)) {
                            itemView(entity: entity)
                        }
                    } else {
                        Text("N/A")
                    }
                }
                .onDelete(perform: deleteEntity)
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
    
    private func deleteEntity(offsets: IndexSet) {
        if !offsets.contains(0) {
            withAnimation {
                viewModel.delete(offsets.map { entities[$0] }, viewContext: viewContext)
            }
        }
    }
}

struct MandelbrotListView_Previews: PreviewProvider {
    static var previews: some View {
        MandelbrotListView()
    }
}
