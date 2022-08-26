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
    
    var defaultMandelbrotEntity: MandelbrotEntity? {
        didSet {
            guard let entity = defaultMandelbrotEntity else {
                return
            }
            
            logger.log("defaultMandelbrotEntity didSet")
            
            let minX = entity.minReal + (0.5  - 0.5 / scale) * (entity.maxReal - entity.minReal)
            let maxX = entity.minReal + (0.5  + 0.5 / scale) * (entity.maxReal - entity.minReal)
            
            let minY = entity.maxImaginary - (0.5 - 0.5 / scale) * (entity.maxImaginary - entity.minImaginary)
            let maxY = entity.maxImaginary - (0.5 + 0.5 / scale) * (entity.maxImaginary - entity.minImaginary)
            
            mandelbrotRect = ComplexRect(Complex<Double>(minX, minY), Complex<Double>(maxX, maxY))
            generateMandelbrotSet()
        }
    }
    
    override init() {
        super.init()
    }
    
    func updateRange(origin: CGPoint, length: CGFloat, originalLength: CGFloat) -> Void {
        guard let defaultMandelbrotEntity = defaultMandelbrotEntity else {
            logger.log("defaultMandelbrotEntity=\(String(describing: self.defaultMandelbrotEntity))")
            return
        }

        self.scale = originalLength / length
        
        let minX = defaultMandelbrotEntity.minReal + (origin.x - 0.5 * length) / originalLength * (defaultMandelbrotEntity.maxReal - defaultMandelbrotEntity.minReal)
        let maxX = defaultMandelbrotEntity.minReal + (origin.x + 0.5 * length) / originalLength * (defaultMandelbrotEntity.maxReal - defaultMandelbrotEntity.minReal)
        
        let minY = defaultMandelbrotEntity.maxImaginary - (origin.y - 0.5 * length) / originalLength * (defaultMandelbrotEntity.maxImaginary - defaultMandelbrotEntity.minImaginary)
        let maxY = defaultMandelbrotEntity.maxImaginary - (origin.y + 0.5 * length) / originalLength * (defaultMandelbrotEntity.maxImaginary - defaultMandelbrotEntity.minImaginary)
        
        mandelbrotRect = ComplexRect(Complex<Double>(minX, minY), Complex<Double>(maxX, maxY))
    }
    
    private var mandelbrotSet: MandelbrotSet?
    private var zs = [Complex<Double>]()
    func generateMandelbrotSet() -> Void {
        let calculationSize = 512
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
        
        mandelbrotSet = MandelbrotSetFactory.createMandelbrotSet(inZs: zs, inMaxIter: maxIter.rawValue, inColorMap: ColorMapFactory.getColorMap(colorMap, length: 256).colorMapInSIMD4)
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
        logger.log("mandelbrotImage=\(String(describing: self.mandelbrotImage))")
    }
    
    func createMandelbrotEntity(viewContext: NSManagedObjectContext) -> Void {
        let mandelbrotEntity = MandelbrotEntity(context: viewContext)
        mandelbrotEntity.minReal = mandelbrotRect.minReal
        mandelbrotEntity.maxReal = mandelbrotRect.maxReal
        mandelbrotEntity.minImaginary = mandelbrotRect.minImaginary
        mandelbrotEntity.maxImaginary = mandelbrotRect.maxImaginary
        mandelbrotEntity.colorMap = colorMap.rawValue
        mandelbrotEntity.maxIter = Int32(maxIter.rawValue)
        mandelbrotEntity.image = mandelbrotImage?.pngData()
        
        save(viewContext: viewContext)
    }
    
    private func save(viewContext: NSManagedObjectContext) -> Void {
        do {
            try viewContext.save()
        } catch {
            logger.log("Error while saving data")
        }
    }
    
    func delete(_ entities: [MandelbrotEntity], viewContext: NSManagedObjectContext) -> Void {
        entities.forEach { viewContext.delete($0) }
        save(viewContext: viewContext)
    }
    
}
