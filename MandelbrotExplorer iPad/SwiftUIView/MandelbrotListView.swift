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
                    if let created = entity.created, let data = entity.image, let uiImage = UIImage(data: data), let colorMap = entity.colorMap {
                        NavigationLink {
                            MandelbrotDetailView(entity: entity,
                                                 minReal: entity.minReal,
                                                 maxReal: entity.maxReal,
                                                 minImaginary: entity.minImaginary,
                                                 maxImaginary: entity.maxImaginary,
                                                 uiImage: uiImage,
                                                 maxIter: MaxIter(rawValue: Int(entity.maxIter)) ?? .twoHundred,
                                                 colorMap: MandelbrotExplorerColorMap(rawValue: colorMap) ?? .jet,
                                                 generator: MandelbrotSetGeneratingDevice(rawValue: entity.generator ?? "cpu") ?? .cpu,
                                                 created: created)
                        } label: {
                            itemView(entity: entity)
                        }
                    } else {
                        Text("N/A")
                    }
                }
                .onDelete(perform: deleteEntity)
            }
        }
        .alert("Failed to save data", isPresented: $viewModel.showAlert) {
            Button("Dismiss", role: .cancel) {
                //
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
            
            VStack(alignment: .leading) {
                Label(entity.centerDescription, systemImage: "dot.viewfinder")
                Label(getFormattedScale(entity: entity), systemImage: "arrow.up.left.and.down.right.magnifyingglass" )
                Label("\(entity.maxIter)", systemImage: "repeat")
                Label(entity.generator ?? "gpu", systemImage: "cpu")
            }
            .fixedSize()
        }
    }
    
    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.minimumSignificantDigits = 2
        formatter.maximumSignificantDigits = 5
        return formatter
    }
    
    private func getFormattedScale(entity: MandelbrotEntity) -> String {
        let scale = viewModel.getScale(entity: entity)
        return scale < 100000 ? String(format: "%.2f", scale) : (formatter.string(from: scale as NSNumber) ?? "unknown")
    }
    
    private func deleteEntity(offsets: IndexSet) {
        if !offsets.contains(0) {
            withAnimation {
                viewModel.delete(offsets.map { entities[$0] }, viewContext: viewContext)
            }
        }
    }
}
