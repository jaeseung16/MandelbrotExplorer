//
//  FirstLaunchView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 9/5/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import SwiftUI

struct FirstLaunchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var viewModel: MandelbrotExplorerViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let hasLaunchedBeforeKey = "HasLaunchedBefore"
    
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Image("firstLaunch")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay {
                    ProgressView("Preparing for the first launch...")
                        .progressViewStyle(.circular)
                }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                viewModel.generateMandelbrotSet()
            }
        }
        .onDisappear() {
            viewModel.toggle.toggle()
        }
        .onChange(of: viewModel.mandelbrotImage, perform: { _ in
            viewModel.firstLaunch(context: viewContext) { success in
                if success {
                    UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
                    dismiss.callAsFunction()
                } else {
                    showAlert = true
                }
            }
        })
        .padding()
        .alert("MandelbrotExplorer", isPresented: $showAlert) {
            Button(role: .destructive) {
                dismiss.callAsFunction()
            } label: {
                Text("OK")
            }
        } message: {
            Text("The app couldn't be initialized. You may need to reinstall the app.")
        }
    }
}
