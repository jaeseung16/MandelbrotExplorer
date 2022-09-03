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
    static func createMandelbrotSet(inZs: [Complex<Double>], inMaxIter: Int, inColorMap: [SIMD4<Float>]) -> MandelbrotSet {
        let mandelbrotSet: MandelbrotSet
        let device = MTLCreateSystemDefaultDevice()
        if device == nil {
            mandelbrotSet = MandelbrotSetCPU(inZs: inZs, inMaxIter: inMaxIter, inColorMap: inColorMap)
        } else {
            mandelbrotSet = MandelbrotSetGPU(inZs: inZs, inMaxIter: inMaxIter, inColorMap: inColorMap)
        }
        return mandelbrotSet
    }
    
    static func createMandelbrotSet(with device: MandelbrotSetGeneratingDevice, inZs: [Complex<Double>], inMaxIter: Int, inColorMap: [SIMD4<Float>]) -> MandelbrotSet {
        let mandelbrotSet: MandelbrotSet
        switch device {
        case .cpu:
            mandelbrotSet = MandelbrotSetCPU(inZs: inZs, inMaxIter: inMaxIter, inColorMap: inColorMap)
        case .gpu:
            mandelbrotSet = MandelbrotSetGPU(inZs: inZs, inMaxIter: inMaxIter, inColorMap: inColorMap)
        case .unknown:
            mandelbrotSet = MandelbrotSetCPU(inZs: inZs, inMaxIter: inMaxIter, inColorMap: inColorMap)
        }
        return mandelbrotSet
    }
}

