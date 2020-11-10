//
//  MandelbrotSetGPU.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/14/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import MetalKit
import ComplexModule

class MandelbrotSetGPU: MandelbrotSet {
    static var device: MTLDevice!
    static var library: MTLLibrary!
    
    static let kernelName = "mandelbrot"
    
    let commandQueue: MTLCommandQueue
    let computePipelineState: MTLComputePipelineState
    let textureDescriptor: MTLTextureDescriptor
    let colorValueTextureDescriptor: MTLTextureDescriptor
    let maxcount: Int
    let bytesPerRow: Int
    let region: MTLRegion
    let colorValueTextureRegion: MTLRegion
    let threadWidth = 32
    
    var inputTexture: MTLTexture
    var outputTexture: MTLTexture
    var colorValueTexture: MTLTexture
    
    var colorMap: [SIMD4<Float>]?
    
    private var _zs: [Complex<Double>]
    var zs: [Complex<Double>] {
        get {
            return _zs
        }
        set {
            _zs = newValue
        }
    }
    
    private var _maxIter: Int
    var maxIter: Int {
        get {
            return _maxIter
        }
        set {
            _maxIter = newValue
        }
    }
    
    private var _values: [Int]
    var values: [Int] {
        get {
            return _values
        }
        set {
            _values = newValue
        }
    }
    
    private var _cgImage: CGImage?
    var cgImage: CGImage {
        get {
            return _cgImage!
        }
        set {
            _cgImage = newValue;
        }
    }
    
    init(inZs: [Complex<Double>], inMaxIter: Int, inColorMap: [SIMD4<Float>]) {
        _zs = inZs
        _maxIter = inMaxIter
        _values = [Int](repeating: 0, count: _zs.count)
        maxcount = Int(sqrt(Float(inZs.count)))
        colorMap = inColorMap
        
        guard inZs.count == maxcount * maxcount else {
            print("inZs.count = \(inZs.count), maxcount = \(maxcount)")
            fatalError("Cannot initialize MandelbrotSetGPU")
        }
        
        guard let device = MTLCreateSystemDefaultDevice(), let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        
        MandelbrotSetGPU.device = device
        self.commandQueue = commandQueue
        
        MandelbrotSetGPU.library = device.makeDefaultLibrary()!
        computePipelineState = MandelbrotSetGPU.createComputePipelineState()
        textureDescriptor = MandelbrotSetGPU.createTextureDescriptor(width: maxcount, height: maxcount)
        
        bytesPerRow = textureDescriptor.width * MemoryLayout<SIMD4<Float>>.stride
        region = MTLRegion(origin: MTLOriginMake(0, 0, 0), size: MTLSizeMake(textureDescriptor.width, textureDescriptor.height, 1))
        
        inputTexture = device.makeTexture(descriptor: textureDescriptor)!
        
        textureDescriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.shaderRead.rawValue)

        outputTexture = device.makeTexture(descriptor: textureDescriptor)!
        
        colorValueTextureDescriptor = MandelbrotSetGPU.createTextureDescriptor(width: 256, height: 1)
        colorValueTextureDescriptor.textureType = .type1D
        colorValueTextureRegion = MTLRegion(origin: MTLOriginMake(0, 0, 0), size: MTLSizeMake(colorValueTextureDescriptor.width, colorValueTextureDescriptor.height, 1))
        colorValueTexture = device.makeTexture(descriptor: colorValueTextureDescriptor)!
    }
    
    func calculate() -> Void{
        populateInputTexture()
        populateColorValueTexture()
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
                return
        }
        
        encode(computeCommandEncoder)
        prepareBlitCommandEncoder(for: commandBuffer)

        commandBuffer.addCompletedHandler { (commandBuffer) in
            print("gpuTime = \(commandBuffer.gpuEndTime - commandBuffer.gpuStartTime)")
        }
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        generateCGImage()
    }
    
    private func encode(_ computeCommandEncoder: MTLComputeCommandEncoder) -> Void {
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        computeCommandEncoder.setTexture(inputTexture, index: 0)
        computeCommandEncoder.setTexture(outputTexture, index: 1)
        computeCommandEncoder.setTexture(colorValueTexture, index: 2)
        
        print("computePipelineState.maxTotalThreadsPerThreadgroup = \(computePipelineState.maxTotalThreadsPerThreadgroup)")
        print("computePipelineState.threadExecutionWidth = \(computePipelineState.threadExecutionWidth)")
        
        let threadHeight = computePipelineState.maxTotalThreadsPerThreadgroup / threadWidth
        
        let numThreadgroups = MTLSize(width: (maxcount + threadWidth) / threadWidth, height: (maxcount + threadHeight) / threadHeight, depth: 1)
        let threadsPerGroup = MTLSize(width: threadWidth, height: threadHeight, depth: 1)
        
        print("numThreadgroups = \(numThreadgroups)")
        print("threadsPerGroup = \(threadsPerGroup)")
        
        computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        computeCommandEncoder.endEncoding()
    }
    
    private func prepareBlitCommandEncoder(for commandBuffer: MTLCommandBuffer) -> Void{
        let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()!
        #if os(macOS)
            blitCommandEncoder.synchronize(resource: outputTexture)
        #endif
        blitCommandEncoder.endEncoding()
    }
    
    private func populateInputTexture() -> Void {
        let zs2 = _zs.map { (z) -> SIMD4<Float> in
            return SIMD4<Float>(x: Float(z.real), y: Float(z.imaginary), z: 0.0, w: 0.0)
        }
        
        inputTexture.replace(region: region, mipmapLevel: 0, withBytes: zs2, bytesPerRow: bytesPerRow)
    }
    
    private func populateColorValueTexture() -> Void {
        var colors = [SIMD4<Float>]()
        
        if (colorMap == nil) {
            for k in 0..<256 {
                colors.append(SIMD4<Float>(x: 0.0, y: Float(k) / 256.0, z: 0.0, w: 1.0))
            }
        } else {
            colors = colorMap!
        }
       
        //print("\(colors[255])")
        
        colorValueTexture.replace(region: colorValueTextureRegion, mipmapLevel: 0, withBytes: colors, bytesPerRow: colorValueTextureDescriptor.width * MemoryLayout<SIMD4<Float>>.stride)
    }
    
    private func generateCGImage() -> Void {
        let ciImageOptions: [CIImageOption: Any] = [.colorSpace: CGColorSpaceCreateDeviceRGB()]
        let ciImage = CIImage(mtlTexture: outputTexture, options: ciImageOptions)!
        
        let contextOptions: [CIContextOption: Any] = [.outputPremultiplied: true,
                              .useSoftwareRenderer: false]
        let context = CIContext(options: contextOptions)
        
        cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
    }
    
    static private func createComputePipelineState() -> MTLComputePipelineState {
        let mandelbrotKernel = MandelbrotSetGPU.library.makeFunction(name: MandelbrotSetGPU.kernelName)
        return try! device.makeComputePipelineState(function: mandelbrotKernel!)
    }
    
    static private func createTextureDescriptor(width: Int, height: Int) -> MTLTextureDescriptor {
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = MTLTextureType.type2D
        descriptor.pixelFormat = MTLPixelFormat.rgba32Float
        descriptor.width = width
        descriptor.height = height
        descriptor.usage = MTLTextureUsage.shaderRead
        return descriptor
    }
}
