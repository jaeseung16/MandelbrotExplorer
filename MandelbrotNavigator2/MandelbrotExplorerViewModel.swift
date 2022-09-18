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
import Persistence
import SwiftUI

class MandelbrotExplorerViewModel: NSObject, ObservableObject {
    let logger = Logger()
    
    private let largestMandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    
    @Published var mandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    @Published var scale = CGFloat(10.0)
    
    @Published var maxIter: MaxIter = .twoHundred
    @Published var colorMap: MandelbrotExplorerColorMap = .jet
    
    @Published var needToRefresh: Bool = false
    @Published var refresh: Bool = false
    @Published var toggle: Bool = false
    @Published var showAlert: Bool = false
    @Published var imageToShare: UIImage?
    @Published var calculating: Bool = false
    @Published var generatingDevice: MandelbrotSetGeneratingDevice = .gpu
    
    @Published var defaultMandelbrotImage: UIImage?
    @Published var mandelbrotImage: UIImage?
    
    @Published var prepared: Bool = false
    
    private var subscriptions: Set<AnyCancellable> = []
    private let calculationSize = 512
    
    var defaultMandelbrotEntity: MandelbrotEntity? {
        didSet {
            guard let entity = defaultMandelbrotEntity else {
                return
            }
            
            logger.log("defaultMandelbrotEntity didSet")
            
            defaultMandelbrotImage = nil
            mandelbrotImage = nil
            
            colorMap = MandelbrotExplorerColorMap(rawValue: entity.colorMap ?? "jet") ?? .jet
            generatingDevice = MandelbrotSetGeneratingDevice(rawValue: entity.generator ?? "gpu") ?? .gpu
            
            // In order to avoid a long wait
            maxIter = .twoHundred
            
            scale = CGFloat(10.0)
        }
    }
    
    private let persistence: Persistence
    var persistenceContainer: NSPersistentContainer {
        persistence.container
    }
    
    init(persistence: Persistence) {
        self.persistence = persistence
        
        super.init()
        
        $needToRefresh
            .throttle(for: 2.0, scheduler: RunLoop.main, latest: true)
            .sink(receiveCompletion: { print("completion: \($0)") },
                  receiveValue: { _ in self.refresh.toggle() })
            .store(in: &subscriptions)
        
        NotificationCenter.default
          .publisher(for: .NSPersistentStoreRemoteChange)
          .sink { self.fetchUpdates($0) }
          .store(in: &subscriptions)
        
        self.persistence.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func prepareExploring() -> Void {
        guard let entity = defaultMandelbrotEntity else {
            return
        }
        
        scale = CGFloat(10.0)
        
        let minX = entity.minReal + (0.5  - 0.5 / scale) * (entity.maxReal - entity.minReal)
        let maxX = entity.minReal + (0.5  + 0.5 / scale) * (entity.maxReal - entity.minReal)
        
        let minY = entity.maxImaginary - (0.5 - 0.5 / scale) * (entity.maxImaginary - entity.minImaginary)
        let maxY = entity.maxImaginary - (0.5 + 0.5 / scale) * (entity.maxImaginary - entity.minImaginary)
        
        mandelbrotRect = ComplexRect(Complex<Double>(minX, minY), Complex<Double>(maxX, maxY))
        generateMandelbrotImage()
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
    func generateMandelbrotSet(within mandelbrotRect: ComplexRect, completionHandler: @escaping ((CGImage) -> Void)) -> Void {
        logger.log("MandelbrotExplorerViewModel.generateMandelbrotSet() called for mandelbrotRect=\(mandelbrotRect, privacy: .public), maxIter = \(self.maxIter.rawValue, privacy: .public), calculationSize=\(self.calculationSize, privacy: .public), calculating=\(self.calculating, privacy: .public)")
        
        let startTime = Date()
        
        zs = [Complex<Double>](repeating: Complex<Double>.zero, count: Int(calculationSize) * Int(calculationSize))
        
        let displaySize = CGSize(width: calculationSize - 1, height: calculationSize - 1)
        for x in 0..<Int(calculationSize) {
            for y in 0..<Int(calculationSize) {
                zs[y * Int(calculationSize) + x] = viewCoordinatesToComplexCoordinates(x: Double(x), y: Double((Int(calculationSize) - 1 - y)), displaySize: displaySize, in: mandelbrotRect)
            }
        }
        
        let timeToPrepare = Date()
    
        mandelbrotSet = MandelbrotSetFactory.createMandelbrotSet(with: generatingDevice, inZs: zs, inMaxIter: maxIter.rawValue, inColorMap: ColorMapFactory.getColorMap(colorMap, length: 256).colorMapInSIMD4)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.mandelbrotSet?.calculate() { cgImage in
                completionHandler(cgImage)
            }
        }
        
        let timeToCalculate = Date()
        
        logger.log("MandelbrotExplorerViewModel.generateMandelbrotSet(): It took \(timeToPrepare.timeIntervalSince(startTime), privacy: .public) seconds to populate inputs")
        
        logger.log("MandelbrotExplorerViewModel.generateMandelbrotSet(): It took \(timeToCalculate.timeIntervalSince(timeToPrepare), privacy: .public) seconds to generate mandelbrotSet")
    }
    
    
    private var defaultMandelbrotRect: ComplexRect {
        guard let entity = defaultMandelbrotEntity else {
            return largestMandelbrotRect
        }
        return ComplexRect(Complex<Double>(entity.minReal, entity.minImaginary), Complex<Double>(entity.maxReal, entity.maxImaginary))
    }
    
    func generateDefaultMandelbrotImage() -> Void {
        let startTime = Date()
        self.calculating.toggle()
        generateMandelbrotSet(within: self.defaultMandelbrotRect) { cgImage in
            guard self.mandelbrotSet != nil else {
                self.logger.log("It was not successful to generate Mandelbrot set within \(self.defaultMandelbrotRect, privacy: .public)")
                return
            }
            
            DispatchQueue.main.async {
                self.defaultMandelbrotImage = UIImage(cgImage: cgImage)
                
                let timeToSetImage = Date()
                self.logger.log("MandelbrotExplorerViewModel.generateDefaultMandelbrotImage(): It took \(timeToSetImage.timeIntervalSince(startTime), privacy: .public) seconds, calculating=\(self.calculating, privacy: .public)")
            
                self.calculating.toggle()
            }
        }
    }
    
    func generateMandelbrotImage() -> Void {
        let startTime = Date()
        self.calculating.toggle()
        generateMandelbrotSet(within: self.mandelbrotRect) { cgImage in
            guard self.mandelbrotSet != nil else {
                self.logger.log("It was not successful to generate Mandelbrot set within \(self.mandelbrotRect, privacy: .public)")
                return
            }
            
            DispatchQueue.main.async {
                self.mandelbrotImage = UIImage(cgImage: cgImage)
                
                let timeToSetImage = Date()
                self.logger.log("MandelbrotExplorerViewModel.generateMandelbrotImage(): It took \(timeToSetImage.timeIntervalSince(startTime)) seconds, calculating=\(self.calculating, privacy: .public)")
            
                self.calculating.toggle()
            }
        }
    }
    
    private func viewCoordinatesToComplexCoordinates(x: Double, y: Double, displaySize: CGSize, in mandelbrotRect: ComplexRect) -> Complex<Double> {
        let minReal = mandelbrotRect.minReal
        let maxReal = mandelbrotRect.maxReal
        let minImaginary = mandelbrotRect.minImaginary
        let maxImaginary = mandelbrotRect.maxImaginary
        
        let r = minReal + ( x / Double(displaySize.width) ) * (maxReal - minReal)
        let i = maxImaginary - ( y / Double(displaySize.height) ) * (maxImaginary - minImaginary)
        return Complex<Double>(r, i)
    }
    
    func update(_ colorMap: MandelbrotExplorerColorMap, isDefault: Bool) -> Void {
        guard let mandelbrotSet = self.mandelbrotSet else {
            print("self.mandelbrotSet is null")
            return
        }
        
        self.colorMap = colorMap
        
        if mandelbrotSet is MandelbrotSetGPU {
            if isDefault {
                generateDefaultMandelbrotImage()
            } else {
                generateMandelbrotImage()
            }
        } else {
            setImage(for: mandelbrotSet, isDefault: isDefault)
        }
    }
    
    private func setImage(for mandelbrotSet: MandelbrotSet?, isDefault: Bool) -> Void {
        guard let mandelbrotSet = self.mandelbrotSet else {
            print("self.mandelbrotSet is null")
            return
        }
        
        if mandelbrotSet is MandelbrotSetGPU {
            if isDefault {
                self.defaultMandelbrotImage = UIImage(cgImage: mandelbrotSet.cgImage)
            } else {
                self.mandelbrotImage = UIImage(cgImage: mandelbrotSet.cgImage)
            }
        } else {
            let mandelbrotImageGenerator: MandelbrotImageGenerator
            mandelbrotImageGenerator = MandelbrotImageGenerator(cgColors: ColorMapFactory.getColorMap(colorMap, length: 256).colorMapInSIMD4)
            mandelbrotImageGenerator.generateCGImage(values: mandelbrotSet.values, lengthOfRow: Int(sqrt(Double(mandelbrotSet.values.count))))
            
            if isDefault {
                self.defaultMandelbrotImage = UIImage(cgImage: mandelbrotImageGenerator.cgImage)
            } else {
                self.mandelbrotImage = UIImage(cgImage: mandelbrotImageGenerator.cgImage)
            }
        }
        logger.log("mandelbrotImage=\(String(describing: self.mandelbrotImage))")
    }
    
    func createMandelbrotEntity(viewContext: NSManagedObjectContext, completionHandler: ((Bool) -> Void)?) -> Void {
        let mandelbrotEntity = MandelbrotEntity(context: viewContext)
        mandelbrotEntity.minReal = mandelbrotRect.minReal
        mandelbrotEntity.maxReal = mandelbrotRect.maxReal
        mandelbrotEntity.minImaginary = mandelbrotRect.minImaginary
        mandelbrotEntity.maxImaginary = mandelbrotRect.maxImaginary
        mandelbrotEntity.colorMap = colorMap.rawValue
        mandelbrotEntity.maxIter = Int32(maxIter.rawValue)
        mandelbrotEntity.image = mandelbrotImage?.pngData()
        mandelbrotEntity.generator = generatingDevice.rawValue
        
        save(viewContext: viewContext, completionHandler: completionHandler)
    }
    
    func update(_ entity: MandelbrotEntity, viewContext: NSManagedObjectContext, completionHandler: ((Bool) -> Void)?) -> Void {
        entity.colorMap = colorMap.rawValue
        entity.maxIter = Int32(maxIter.rawValue)
        entity.image = defaultMandelbrotImage?.pngData()
        entity.generator = generatingDevice.rawValue
        entity.lastupd = Date()
        
        save(viewContext: viewContext, completionHandler: completionHandler)
    }
    
    private func save(viewContext: NSManagedObjectContext, completionHandler: ((Bool) -> Void)?) -> Void {
        persistence.save { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.toggle.toggle()
                    if completionHandler != nil {
                        completionHandler!(true)
                    }
                }
            case .failure(let error):
                self.logger.log("Error while saving data: \(error.localizedDescription, privacy: .public)")
                self.logger.log("Error while saving data: \(Thread.callStackSymbols, privacy: .public)")
                DispatchQueue.main.async {
                    self.showAlert.toggle()
                    if completionHandler != nil {
                        completionHandler!(false)
                    }
                }
            }
        }
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
    
    func generateImage(from viewToShare: ShareView) {
        let controller = UIHostingController(rootView: viewToShare)
        
        if let view = controller.view {
            let targetSize = view.intrinsicContentSize
            
            view.bounds = CGRect(origin: .zero, size: targetSize)
            view.backgroundColor = .clear
            
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let renderedImage = renderer.image { _ in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
            
            imageToShare = renderedImage
        }
    }
    
    func isTooSmallToUseGPU() -> Bool {
        let diffReal = Float(mandelbrotRect.maxReal - mandelbrotRect.minReal)
        let diffImaginary = Float(mandelbrotRect.maxImaginary - mandelbrotRect.minImaginary)
        let allowedDiff = Float.ulpOfOne * Float(calculationSize) / 2.0
        return diffReal < allowedDiff || diffImaginary < allowedDiff
    }
    
    private let originalRange = 3.0
    func getScale(entity: MandelbrotEntity) -> Double {
        return originalRange / (entity.maxReal - entity.minReal)
    }
    
    func firstLaunch(context: NSManagedObjectContext, completionHandler: ((Bool) -> Void)?) -> Void {
        let entityCount = persistence.count("MandelbrotEntity")
        
        logger.log("firstLaunch: entityCount=\(entityCount, privacy: .public)")
        if entityCount < 1 {
            createMandelbrotEntity(viewContext: context, completionHandler: completionHandler)
        } else {
            completionHandler?(true)
        }
    }
    
    // MARK: - Persistence History Request
    private lazy var historyRequestQueue = DispatchQueue(label: "history")
    private func fetchUpdates(_ notification: Notification) -> Void {
        persistence.fetchUpdates(notification) { result in
            switch result {
            case .success(()):
                DispatchQueue.main.async {
                    self.toggle.toggle()
                }
            case .failure(let error):
                self.logger.log("Error while updating history: \(error.localizedDescription, privacy: .public) \(Thread.callStackSymbols, privacy: .public)")
            }
        }
    }
}
