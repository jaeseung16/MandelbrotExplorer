//
//  MandelbrotSetFactory.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 7/3/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import MetalKit
import ComplexModule

class MandelbrotSetFactory {
    static func createMandelbrotSet(inZs: [Complex<Double>], inMaxIter: Int) -> MandelbrotSet {
        let mandelbrotSet: MandelbrotSet
        
        let device = MTLCreateSystemDefaultDevice()
        if (device == nil) {
            print("Using CPU")
            mandelbrotSet = MandelbrotSetCPU(inZs: inZs, inMaxIter: 200)
        } else {
            print("Using GPU")
            mandelbrotSet = MandelbrotSetGPU(inZs: inZs, inMaxIter: 200)
        }
        
        return mandelbrotSet
    }
}

