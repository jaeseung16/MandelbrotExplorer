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
    
    var mandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    var scale = CGFloat(10.0)
    
    var maxIter: MaxIter = .twoHundred
    var colorMap: MandelbrotExplorerColorMap = .jet
    
    @Published var toggle: Bool = false
    @Published var showAlert: Bool = false
    @Published var imageToShare: UIImage?
    var generatingDevice: MandelbrotSetGeneratingDevice = .gpu
    
    @Published var defaultMandelbrotImage: UIImage?
    var mandelbrotImage: UIImage?
    
    @Published var prepared: Bool = false
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private var defaultMandelbrotSet: MandelbrotSet?
    private var mandelbrotSet: MandelbrotSet?
    
    private var defaultMandelbrotRect: ComplexRect {
        guard let entity = defaultMandelbrotEntity else {
            return largestMandelbrotRect
        }
        return ComplexRect(Complex<Double>(entity.minReal, entity.minImaginary), Complex<Double>(entity.maxReal, entity.maxImaginary))
    }
    
    var defaultMandelbrotEntity: MandelbrotEntity? {
        didSet {
            logger.log("defaultMandelbrotEntity didSet")
            defaultMandelbrotImage = nil
            mandelbrotImage = nil
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
        
        NotificationCenter.default
          .publisher(for: .NSPersistentStoreRemoteChange)
          .sink { self.fetchUpdates($0) }
          .store(in: &subscriptions)
        
        self.persistence.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func prepareExploring(completionHandler: ((UIImage?) -> Void)? = nil) -> Void {
        guard let entity = defaultMandelbrotEntity else {
            return
        }
        
        let parameters = MandelbrotExplorerParameters(
            maxIter: MaxIter(rawValue: Int(entity.maxIter)) ?? .twoHundred,
            colorMap: MandelbrotExplorerColorMap(rawValue: entity.colorMap ?? "jet") ?? .jet,
            generatingDevice: MandelbrotSetGeneratingDevice(rawValue: entity.generator ?? "gpu") ?? .gpu
        )
        
        scale = CGFloat(10.0)
        
        let minX = entity.minReal + (0.5  - 0.5 / scale) * (entity.maxReal - entity.minReal)
        let maxX = entity.minReal + (0.5  + 0.5 / scale) * (entity.maxReal - entity.minReal)
        
        let minY = entity.maxImaginary - (0.5 - 0.5 / scale) * (entity.maxImaginary - entity.minImaginary)
        let maxY = entity.maxImaginary - (0.5 + 0.5 / scale) * (entity.maxImaginary - entity.minImaginary)
        
        mandelbrotRect = ComplexRect(Complex<Double>(minX, minY), Complex<Double>(maxX, maxY))
        
        generateMandelbrotImage(within: mandelbrotRect, parameters: parameters) {
            completionHandler?(self.mandelbrotImage)
        }
        
        logger.log("prepareExploring finished")
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
        
        logger.log("Updated mandelbrotRect=\(self.mandelbrotRect, privacy: .public)")
    }
    
    func generateDefaultMandelbrotImage(parameters: MandelbrotExplorerParameters, completionHandler: (() -> Void)? = nil) -> Void {
        let startTime = Date()
        MandelbrotExplorerHelper.generateMandelbrotSet(within: self.defaultMandelbrotRect,
                                                       maxIter: parameters.maxIter.rawValue,
                                                       size: MandelbrotExplorerParameters.calculationSize,
                                                       colorMap: ColorMapFactory.getColorMap(parameters.colorMap, length: 256),
                                                       device: parameters.generatingDevice) { mandelbrotSet, cgImage in
            self.defaultMandelbrotSet = mandelbrotSet
            
            DispatchQueue.main.async {
                self.defaultMandelbrotImage = UIImage(cgImage: cgImage)
                
                let timeToSetImage = Date()
                self.logger.log("MandelbrotExplorerViewModel.generateDefaultMandelbrotImage(): It took \(timeToSetImage.timeIntervalSince(startTime), privacy: .public) seconds")
                
                completionHandler?()
            }
        }
    }
    
    func generateMandelbrotImage(within mandelbrotRect: ComplexRect, parameters: MandelbrotExplorerParameters, completionHandler: (() -> Void)? = nil) -> Void {
        let startTime = Date()
        self.update(parameters: parameters)
        MandelbrotExplorerHelper.generateMandelbrotSet(within: mandelbrotRect,
                                                       maxIter: parameters.maxIter.rawValue,
                                                       size: MandelbrotExplorerParameters.calculationSize,
                                                       colorMap: ColorMapFactory.getColorMap(parameters.colorMap, length: 256),
                                                       device: parameters.generatingDevice) { mandelbrotSet, cgImage in
            self.mandelbrotSet = mandelbrotSet
            
            DispatchQueue.main.async {
                self.mandelbrotImage = UIImage(cgImage: cgImage)
                
                let timeToSetImage = Date()
                self.logger.log("MandelbrotExplorerViewModel.generateDefaultMandelbrotImage(): It took \(timeToSetImage.timeIntervalSince(startTime), privacy: .public) seconds")
                
                completionHandler?()
            }
        }
    }
    
    private func update(parameters: MandelbrotExplorerParameters) -> Void {
        self.colorMap = parameters.colorMap
        self.maxIter = parameters.maxIter
        self.generatingDevice = parameters.generatingDevice
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
    
    func update(_ entity: MandelbrotEntity, parameters: MandelbrotExplorerParameters, viewContext: NSManagedObjectContext, completionHandler: ((Bool) -> Void)?) -> Void {
        entity.colorMap = parameters.colorMap.rawValue
        entity.maxIter = Int32(parameters.maxIter.rawValue)
        entity.image = defaultMandelbrotImage?.pngData()
        entity.generator = parameters.generatingDevice.rawValue
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
        let allowedDiff = Float.ulpOfOne * Float(MandelbrotExplorerParameters.calculationSize) / 2.0
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
            mandelbrotImage = defaultMandelbrotImage
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
