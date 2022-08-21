//
//  MandelbrotExplorerViewModel.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 8/21/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import Foundation
import Combine
import CoreData
import os
import ComplexModule

class MandelbrotExplorerViewModel: NSObject, ObservableObject {
    let logger = Logger()
    
    @Published var mandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    //@Published var range: CGRect
    @Published var scale = CGFloat(10.0)
    
    override init() {
        super.init()
    }
    
    func updateRange(origin: CGPoint, length: CGFloat, originalLength: CGFloat, defaultMandelbrotEntity: MandelbrotEntity) -> Void {
        self.scale = originalLength / length
        
        let minX = defaultMandelbrotEntity.minReal + (origin.x - 0.5 * length) / originalLength * (defaultMandelbrotEntity.maxReal - defaultMandelbrotEntity.minReal)
        let maxX = defaultMandelbrotEntity.minReal + (origin.x + 0.5 * length) / originalLength * (defaultMandelbrotEntity.maxReal - defaultMandelbrotEntity.minReal)
        
        let minY = defaultMandelbrotEntity.maxImaginary - (origin.y - 0.5 * length) / originalLength * (defaultMandelbrotEntity.maxImaginary - defaultMandelbrotEntity.minImaginary)
        let maxY = defaultMandelbrotEntity.maxImaginary - (origin.y + 0.5 * length) / originalLength * (defaultMandelbrotEntity.maxImaginary - defaultMandelbrotEntity.minImaginary)
        
        mandelbrotRect = ComplexRect(Complex<Double>(minX, minY), Complex<Double>(maxX, maxY))
        
    }
    
}
