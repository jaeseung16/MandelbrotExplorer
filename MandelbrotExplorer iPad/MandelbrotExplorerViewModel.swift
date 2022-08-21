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
import UIKit

class MandelbrotExplorerViewModel: NSObject, ObservableObject {
    let logger = Logger()
    
    @Published var mandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    //@Published var range: CGRect
    @Published var scale = CGFloat(10.0)
    
    @Published var maxIter: MaxIter = .twoHundred
    @Published var colorMap: MandelbrotExplorerColorMap = .green
    
    
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
    
    private var mandelbrotSet: MandelbrotSet?
    private var zs = [Complex<Double>]()
    func generateMandelbrotSet(calculationSize: CGFloat) -> Void {
        logger.log("MandelbrotDisplay.generateMandelbrotSet() called for mandelbrotRect=\(self.mandelbrotRect), maxIter = \(self.maxIter.rawValue), calculationSize=\(calculationSize)")
        
        let startTime = Date()
        
        zs = [Complex<Double>](repeating: Complex<Double>.zero, count: Int(calculationSize) * Int(calculationSize))
        
        let displaySize = CGSize(width: calculationSize - 1, height: calculationSize - 1)
        for x in 0..<Int(calculationSize) {
            for y in 0..<Int(calculationSize) {
                zs[y * Int(calculationSize) + x] = viewCoordinatesToComplexCoordinates(x: Double(x), y: Double((Int(calculationSize) - 1 - y)), displaySize: displaySize)
            }
        }
        
        let timeToPrepare = Date()
        
        mandelbrotSet = MandelbrotSetFactory.createMandelbrotSet(inZs: zs, inMaxIter: maxIter.rawValue, inColorMap: ColorMapFactory.getColorMap(.jet, length: 256).colorMapInSIMD4)
        mandelbrotSet?.calculate()
        
        let timeToCalculate = Date()
        
        setImage(for: mandelbrotSet)
        
        let timeToSetImage = Date()
            
        logger.log("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToPrepare.timeIntervalSince(startTime)) seconds to populate inputs")
        
        logger.log("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToCalculate.timeIntervalSince(timeToPrepare)) seconds to generate mandelbrotSet")
            
        logger.log("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToSetImage.timeIntervalSince(timeToCalculate)) seconds")
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
    
    @Published var mandelbrotImage: UIImage?
    private func setImage(for mandelbrotSet: MandelbrotSet?) -> Void {
        guard let mandelbrotSet = self.mandelbrotSet else {
            print("self.mandelbrotSet is null")
            return
        }
        
        if mandelbrotSet is MandelbrotSetGPU {
            self.mandelbrotImage = UIImage(cgImage: mandelbrotSet.cgImage)
        } else {
            let mandelbrotImageGenerator: MandelbrotImageGenerator
            mandelbrotImageGenerator = MandelbrotImageGenerator(cgColors: ColorMapFactory.getColorMap(colorMap, length: 256).colorMapInSIMD4)
            mandelbrotImageGenerator.generateCGImage(values: mandelbrotSet.values, lengthOfRow: Int(sqrt(Double(mandelbrotSet.values.count))))
            
            self.mandelbrotImage = UIImage(cgImage: mandelbrotImageGenerator.cgImage)
        }
    }
}
