//
//  MandelbrotExplorerHelper.swift
//  MandelbrotNavigator2
//
//  Created by Jae Seung Lee on 9/18/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import Foundation
import os
import ComplexModule
import CoreGraphics

class MandelbrotExplorerHelper {
    static let logger = Logger()
    
    static func generateMandelbrotSet(within mandelbrotRect: ComplexRect, maxIter: Int, size: Int, colorMap: ColorMap, device: MandelbrotSetGeneratingDevice, completionHandler: @escaping ((MandelbrotSet, CGImage) -> Void)) -> Void {
        logger.log("MandelbrotExplorerHelper.generateMandelbrotSet() called for mandelbrotRect=\(mandelbrotRect, privacy: .public), maxIter = \(maxIter, privacy: .public), calculationSize=\(size, privacy: .public), device=\(device.rawValue, privacy: .public)")
        
        let startTime = Date()
        
        var zs = [Complex<Double>](repeating: Complex<Double>.zero, count: Int(size) * Int(size))
        
        let displaySize = CGSize(width: size - 1, height: size - 1)
        for x in 0..<Int(size) {
            for y in 0..<Int(size) {
                zs[y * Int(size) + x] = viewCoordinatesToComplexCoordinates(x: Double(x), y: Double((Int(size) - 1 - y)), displaySize: displaySize, in: mandelbrotRect)
            }
        }
        
        let timeToPrepare = Date()
    
        let mandelbrotSet = MandelbrotSetFactory.createMandelbrotSet(with: device, inZs: zs, inMaxIter: maxIter, inColorMap: colorMap.colorMapInSIMD4)
        
        DispatchQueue.global(qos: .userInitiated).async {
            mandelbrotSet.calculate() { cgImage in
                logger.log("MandelbrotExplorerHelper.generateMandelbrotSet(): calling completionHandler")
                completionHandler(mandelbrotSet, cgImage)
            }
        }
        
        let timeToCalculate = Date()
        
        logger.log("MandelbrotExplorerHelper.generateMandelbrotSet(): It took \(timeToPrepare.timeIntervalSince(startTime), privacy: .public) seconds to populate inputs")
        
        logger.log("MandelbrotExplorerHelper.generateMandelbrotSet(): It took \(timeToCalculate.timeIntervalSince(timeToPrepare), privacy: .public) seconds to generate mandelbrotSet")
    }
    
    private static func viewCoordinatesToComplexCoordinates(x: Double, y: Double, displaySize: CGSize, in mandelbrotRect: ComplexRect) -> Complex<Double> {
        let minReal = mandelbrotRect.minReal
        let maxReal = mandelbrotRect.maxReal
        let minImaginary = mandelbrotRect.minImaginary
        let maxImaginary = mandelbrotRect.maxImaginary
        
        let r = minReal + ( x / Double(displaySize.width) ) * (maxReal - minReal)
        let i = maxImaginary - ( y / Double(displaySize.height) ) * (maxImaginary - minImaginary)
        return Complex<Double>(r, i)
    }
    
}
