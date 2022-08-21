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
    
    func updateRange(origin: CGPoint, length: CGFloat, scale: CGFloat) -> Void {
        let minX = origin.x - 0.5 * length
        let maxX = origin.x + 0.5 * length
        let minY = origin.y - 0.5 * length
        let maxY = origin.y + 0.5 * length
        mandelbrotRect = ComplexRect(Complex<Double>(minX, maxX), Complex<Double>(minY, maxY))
        
        self.scale = scale
    }
    
}
