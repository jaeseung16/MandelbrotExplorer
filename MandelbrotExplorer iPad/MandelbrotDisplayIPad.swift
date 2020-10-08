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
    
    var zs: [Complex<Double>]
    
    var mandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    var mandelbrotSet: MandelbrotSet?
    var mandelbrotImage: UIImage?
    
    var id: MandelbrotID?
    
    init(sideLength: Int) {
        self.sideLength = sideLength + 1
        let numberOfPixels = self.sideLength * self.sideLength
        
        self.zs = [Complex<Double>](repeating: Complex<Double>.zero, count: numberOfPixels)
    }
    
    func setMandelbrotRect(realOrigin: Double, imaginrayOrigin: Double, realRange: Double, imaginaryRange: Double) {
        mandelbrotRect = ComplexRect(Complex<Double>(realOrigin, imaginrayOrigin), Complex<Double>(realOrigin + realRange, imaginrayOrigin + imaginaryRange))
    }
    
    func generateMandelbrotSet() -> Void {
        print("MandelbrotDisplay.generateMandelbrotSet() called for \(mandelbrotRect) with sideLength = \(sideLength)")
        
        let startTime = Date()
        
        let displaySize = CGSize(width: sideLength - 1, height: sideLength - 1)
        for x in 0..<sideLength {
            for y in 0..<sideLength {
                zs[y * sideLength + x] = viewCoordinatesToComplexCoordinates(x: Double(x), y: Double((sideLength - 1 - y)), displaySize: displaySize)
            }
        }
        
        let timeToPrepare = Date()
        
        mandelbrotSet = MandelbrotSetFactory.createMandelbrotSet(inZs: zs, inMaxIter: 200)
        mandelbrotSet?.calculate()
        
        let timeToCalculate = Date()
        
        setImage(for: mandelbrotSet)
        
        let timeToSetImage = Date()
            
        print("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToPrepare.timeIntervalSince(startTime)) seconds to populate inputs")
        
        print("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToCalculate.timeIntervalSince(timeToPrepare)) seconds to generate mandelbrotSet")
            
        print("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToSetImage.timeIntervalSince(timeToCalculate)) seconds")
    }
    
    private func viewCoordinatesToComplexCoordinates(x: Double, y: Double, displaySize: CGSize) -> Complex<Double> {
        let minReal = mandelbrotRect.minReal
        let maxReal = mandelbrotRect.maxReal
        let minImaginary = mandelbrotRect.minImaginary
        let maxImaginary = mandelbrotRect.maxImaginary
        
        let r = minReal + ( x / Double(displaySize.width) ) * (maxReal - minReal)
        let i = minImaginary + ( y / Double(displaySize.height) ) * (maxImaginary - minImaginary)
        return Complex<Double>(r, i)
    }
    
    static func viewCoordinatesToComplexCoordinates(x: Double, y: Double, displaySize: CGSize, in complexRect: ComplexRect) -> Complex<Double> {
        let minReal = complexRect.minReal
        let maxReal = complexRect.maxReal
        let minImaginary = complexRect.minImaginary
        let maxImaginary = complexRect.maxImaginary
        
        let r = minReal + ( x / Double(displaySize.width) ) * (maxReal - minReal)
        let i = (maxImaginary - minImaginary) / 2.0 - ( y / Double(displaySize.height) ) * (maxImaginary - minImaginary)
        return Complex<Double>(r, i)
    }
    
    func updateChild(rect: CGRect) {
        guard let child = child else {
            return
        }
        
        let tl = viewCoordinatesToComplexCoordinates(x: Double(rect.minX), y: Double(rect.minY), displaySize: CGSize(width: sideLength, height: sideLength))
        let br = viewCoordinatesToComplexCoordinates(x: Double(rect.maxX), y: Double(rect.maxY), displaySize: CGSize(width: sideLength, height: sideLength))
        
        print("tl = \(tl)")
        print("br = \(br)")
        child.mandelbrotRect = ComplexRect(tl, br)
        child.generateMandelbrotSet()
    }
    
    private func setImage(for mandelbrotSet: MandelbrotSet?) -> Void {
        guard let mandelbrotSet = self.mandelbrotSet else {
            print("self.mandelbrotSet is null")
            return
        }
        
        print("mandelbrotSet = \(mandelbrotSet)")
        self.mandelbrotImage = UIImage(cgImage: mandelbrotSet.cgImage)
    }
    
}
