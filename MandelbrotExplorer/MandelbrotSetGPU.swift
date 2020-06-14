//
//  MandelbrotSetGPU.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/14/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import MetalKit

class MandelbrotSetGPU: MandelbrotSet {
    static var device: MTLDevice!
    static var library: MTLLibrary!
    
    static let kernelName = "mandelbrot"
    
    let commandQueue: MTLCommandQueue
    let computePipelineState: MTLComputePipelineState
    let textureDescriptor: MTLTextureDescriptor
    let maxcount: Int
    let bytesPerRow: Int
    let region: MTLRegion
    
    var inputTexture: MTLTexture
    var outputTexture: MTLTexture
    
    var _zs: [Complex]
    var zs: [Complex] {
        get {
            return _zs
        }
        set {
            _zs = newValue
        }
    }
    
    var _maxIter: Int
    var maxIter: Int {
        get {
            return _maxIter
        }
        set {
            _maxIter = newValue
        }
    }
    
    var _values: [Int]
    var values: [Int] {
        get {
            return _values
        }
        set {
            _values = newValue
        }
    }
    
    init(inZs: [Complex], inMaxIter: Int) {
        _zs = inZs
        _maxIter = inMaxIter
        _values = [Int](repeating: 0, count: _zs.count)
        maxcount = Int(sqrt(Float(inZs.count)))
        
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
        
        calculate()
    }
    
    func calculate() -> Void{
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
                return
        }
        
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        
        let zs2 = _zs.map { (z) -> SIMD4<Float> in
            return SIMD4<Float>(x: Float(z.real), y: Float(z.imaginary), z: 0.0, w: 0.0)
        }
        
        inputTexture.replace(region: region, mipmapLevel: 0, withBytes: zs2, bytesPerRow: bytesPerRow)
        
        computeCommandEncoder.setTexture(inputTexture, index: 0)
        computeCommandEncoder.setTexture(outputTexture, index: 1)
        
        print("computePipelineState.maxTotalThreadsPerThreadgroup = \(computePipelineState.maxTotalThreadsPerThreadgroup)")
        print("computePipelineState.threadExecutionWidth = \(computePipelineState.threadExecutionWidth)")
        
        // hardcoded to 32 for now (recommendation: read about threadExecutionWidth)
        let threadWidth = 32
        let numThreadgroups = MTLSize(width: (maxcount + threadWidth) / threadWidth, height: (maxcount + threadWidth) / threadWidth, depth: 1)
        let threadsPerGroup = MTLSize(width: threadWidth, height: threadWidth, depth: 1)
        computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        computeCommandEncoder.endEncoding()
        
        let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitCommandEncoder.synchronize(resource: outputTexture)
        blitCommandEncoder.endEncoding()
        
        commandBuffer.addCompletedHandler { (commandBuffer) in
            print("gpuStartTime = \(commandBuffer.gpuStartTime)")
            print("gpuEndTime = \(commandBuffer.gpuEndTime)")
            print("gpuTime = \(commandBuffer.gpuEndTime - commandBuffer.gpuStartTime)")
        }
        
        commandBuffer.commit()
            
        commandBuffer.waitUntilCompleted()
        
        let data = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<SIMD4<Float>>.stride * textureDescriptor.width * textureDescriptor.height, alignment: MemoryLayout<SIMD4<Float>>.stride)
        
        defer {
          data.deallocate()
        }
        
        outputTexture.getBytes(data, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
        for k in 0..<maxcount {
            for l in 0..<maxcount {
                let offset = (k * maxcount + l) * MemoryLayout<SIMD4<Float>>.stride
                
                let offsetPointer = data.advanced(by: offset)
                _values[k * maxcount + l] = Int(offsetPointer.load(as: SIMD4<Float>.self).x)
            }
        }
    }
    
    static func createComputePipelineState() -> MTLComputePipelineState {
        let mandelbrotKernel = MandelbrotSetGPU.library.makeFunction(name: MandelbrotSetGPU.kernelName)
        return try! device.makeComputePipelineState(function: mandelbrotKernel!)
    }
    
    static func createTextureDescriptor(width: Int, height: Int) -> MTLTextureDescriptor {
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = MTLTextureType.type2D
        descriptor.pixelFormat = MTLPixelFormat.rgba32Float
        descriptor.width = width
        descriptor.height = height
        descriptor.usage = MTLTextureUsage.shaderRead
        return descriptor
    }
}
