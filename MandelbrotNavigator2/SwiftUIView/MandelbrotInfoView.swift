//
//  MandelbrotInfoView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 8/27/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import SwiftUI
import ComplexModule

struct MandelbrotInfoView: View {
    
    let minReal: Double
    let maxReal: Double
    let minImaginary: Double
    let maxImaginary: Double
    
    private var bottomLeft: Complex<Double> {
        Complex<Double>(minReal, minImaginary)
    }
    
    private var topRight: Complex<Double> {
        Complex<Double>(maxReal, maxImaginary)
    }
    
    var body: some View {
        VStack {
            Text("Bottom Left: (\(minReal), \(minImaginary))")
            
            Text("Top Right: (\(maxReal), \(maxImaginary))")
        }
    }
    
}
