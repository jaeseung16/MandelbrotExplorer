//
//  ZoomedMandelbrotView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 8/20/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import SwiftUI

struct ZoomedMandelbrotView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: MandelbrotExplorerViewModel
    
    var body: some View {
        Rectangle()
            .strokeBorder(Color.green, lineWidth: 2.0)
    }
}

struct ZoomedMandelbrotView_Previews: PreviewProvider {
    static var previews: some View {
        ZoomedMandelbrotView()
    }
}
