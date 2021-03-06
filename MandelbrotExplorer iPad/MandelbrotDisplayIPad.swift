//
//  MandelbrotDisplayIPad.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/5/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import UIKit
import ComplexModule

class MandelbrotDisplayIPad {
    var child: MandelbrotDisplayIPad?
    
    var sideLength: Int
    var maxIter: Int
    
    var zs: [Complex<Double>]
    
    var mandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    var mandelbrotSet: MandelbrotSet?
    var mandelbrotImage: UIImage?
    
    var id: MandelbrotID?
    var colorMap: [SIMD4<Float>]?
    
    init(sideLength: Int, maxIter: Int) {
        self.sideLength = sideLength + 1
        self.maxIter = maxIter
        
        let numberOfPixels = self.sideLength * self.sideLength
        self.zs = [Complex<Double>](repeating: Complex<Double>.zero, count: numberOfPixels)
    }
    
    func setMandelbrotRect(realOrigin: Double, imaginrayOrigin: Double, realRange: Double, imaginaryRange: Double) {
        mandelbrotRect = ComplexRect(Complex<Double>(realOrigin, imaginrayOrigin), Complex<Double>(realOrigin + realRange, imaginrayOrigin + imaginaryRange))
    }
    
    func generateMandelbrotSet() -> Void {
        NSLog("MandelbrotDisplay.generateMandelbrotSet() called for \(mandelbrotRect) with sideLength = \(sideLength) and maxIter = \(maxIter)")
        
        let startTime = Date()
        
        let displaySize = CGSize(width: sideLength - 1, height: sideLength - 1)
        for x in 0..<sideLength {
            for y in 0..<sideLength {
                zs[y * sideLength + x] = viewCoordinatesToComplexCoordinates(x: Double(x), y: Double((sideLength - 1 - y)), displaySize: displaySize)
            }
        }
        
        let timeToPrepare = Date()
        
        mandelbrotSet = MandelbrotSetFactory.createMandelbrotSet(inZs: zs, inMaxIter: maxIter, inColorMap: colorMap!)
        mandelbrotSet?.calculate()
        
        let timeToCalculate = Date()
        
        setImage(for: mandelbrotSet)
        
        let timeToSetImage = Date()
            
        NSLog("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToPrepare.timeIntervalSince(startTime)) seconds to populate inputs")
        
        NSLog("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToCalculate.timeIntervalSince(timeToPrepare)) seconds to generate mandelbrotSet")
            
        NSLog("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToSetImage.timeIntervalSince(timeToCalculate)) seconds")
    }
    
    private func viewCoordinatesToComplexCoordinates(x: Double, y: Double, displaySize: CGSize) -> Complex<Double> {
        let minReal = mandelbrotRect.minReal
        let maxReal = mandelbrotRect.maxReal
        let minImaginary = mandelbrotRect.minImaginary
        let maxImaginary = mandelbrotRect.maxImaginary
        
        let r = minReal + ( x / Double(displaySize.width) ) * (maxReal - minReal)
        let i = maxImaginary - ( y / Double(displaySize.height) ) * (maxImaginary - minImaginary)
        return Complex<Double>(r, i)
    }
    
    func updateChild(rect: CGRect) {
        guard let child = child else {
            return
        }
        
        let tl = viewCoordinatesToComplexCoordinates(x: Double(rect.minX), y: Double(rect.minY), displaySize: CGSize(width: sideLength, height: sideLength))
        let br = viewCoordinatesToComplexCoordinates(x: Double(rect.maxX), y: Double(rect.maxY), displaySize: CGSize(width: sideLength, height: sideLength))
        
        child.mandelbrotRect = ComplexRect(tl, br)
        child.generateMandelbrotSet()
    }
    
    private func setImage(for mandelbrotSet: MandelbrotSet?) -> Void {
        guard let mandelbrotSet = self.mandelbrotSet else {
            print("self.mandelbrotSet is null")
            return
        }
        
        if mandelbrotSet is MandelbrotSetGPU {
            self.mandelbrotImage = UIImage(cgImage: mandelbrotSet.cgImage)
        } else {
            let mandelbrotImageGenerator: MandelbrotImageGenerator
            mandelbrotImageGenerator = MandelbrotImageGenerator(cgColors: colorMap!)
            mandelbrotImageGenerator.generateCGImage(values: mandelbrotSet.values, lengthOfRow: Int(sqrt(Double(mandelbrotSet.values.count))))
            
            self.mandelbrotImage = UIImage(cgImage: mandelbrotImageGenerator.cgImage)
        }
    }
}
