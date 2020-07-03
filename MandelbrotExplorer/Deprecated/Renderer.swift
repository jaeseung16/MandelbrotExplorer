//
//  Renderer.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/2/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import MetalKit

struct Vertex {
    let position: SIMD3<Float>
    let texture: SIMD2<Float>
}

struct Mandelbrot {
    var origin: CGPoint
    var delta: CGPoint
    var zoom: Float
}

struct MandelbrotComplex {
    var real: Float
    var imag: Float
}

class Renderer: NSObject {
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    static var library: MTLLibrary!
    let pipelineState: MTLRenderPipelineState
    let computePipelineState: MTLComputePipelineState
    let computeCommandEncoder: MTLComputeCommandEncoder
    let maxcount = 300
    let blockiness: CGFloat = 1.0
    var outmemory: [[UInt8]]
    var mandelbrotImage: NSImage?
    let textureDescriptor = MTLTextureDescriptor()
    var inputTexture: MTLTexture
    var outputTexture: MTLTexture
  
    let vertices: [Vertex] = [
        Vertex(position: SIMD3<Float>(-1.0, -1.0, 0), texture: SIMD2<Float>(0, 0)),
        Vertex(position: SIMD3<Float>(-1.0, 1.0, 0), texture: SIMD2<Float>(0, 1)),
        Vertex(position: SIMD3<Float>(1.0, -1.0, 0), texture: SIMD2<Float>(1, 0)),
        Vertex(position: SIMD3<Float>(1.0, 1.0, 0), texture: SIMD2<Float>(1, 1))
    ]
    
    let indexArray: [uint16] = [
        0, 1, 2,
        2, 1, 3
    ]
    
    let mandelbrot = Mandelbrot(origin: CGPoint(x: -2.1, y: -1.5), delta: CGPoint(x: 3.0, y: 3.0), zoom: 1.0)

    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let mandelbrotBuffer: MTLBuffer
  
    var timer: Float = 0
  
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(), let commandQueue = device.makeCommandQueue() else {
                fatalError("Unable to connect to GPU")
        }
        
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()!
        pipelineState = Renderer.createPipelineState()
        
        //let sigmoidKernel = Renderer.library.makeFunction(name: "sigmoid")
        let mandelbrotKernel = Renderer.library.makeFunction(name: "mandelbrot")
        computePipelineState = try! device.makeComputePipelineState(function: mandelbrotKernel!)
        
        
        textureDescriptor.textureType = MTLTextureType.type2D
        textureDescriptor.pixelFormat = MTLPixelFormat.rgba32Float
        textureDescriptor.width = maxcount + 1
        textureDescriptor.height = maxcount + 1
        textureDescriptor.usage = MTLTextureUsage.shaderRead
        
        let commandBuffer = self.commandQueue.makeCommandBuffer()!
        computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        
        let numCount = (maxcount + 1) * (maxcount + 1)
        let byteCount: Int = numCount * MemoryLayout<MandelbrotComplex>.stride
        
        var zs = Array(repeating: Array(repeating: MandelbrotComplex(real: 0.0, imag: 0.0), count: maxcount + 1), count: maxcount+1)
        
        //var zs2 = Array(repeating: Array(repeating: SIMD4<Float>(0.0, 0.0, 0.0, 0.0), count: maxcount + 1), count: maxcount+1)
        
        var zs2 = Array(repeating: SIMD4<Float>(0.0, 0.0, 0.0, 0.0), count: (maxcount + 1) * (maxcount+1))
        
        let mandelbrotRect = ComplexRect(Complex(-2.1, -1.5), Complex(0.9, 1.5))
        
        for x in stride(from: 0, through: Double(maxcount), by: Double(blockiness)) {
            for y in stride(from: 0, through: Double(maxcount), by: Double(blockiness)) {
                zs[Int(x)][Int(y)] = Renderer.viewCoordinatesToComplexCoordinates(x: Float(x), y: Float(y), rect: CGRect(x: 0, y: 0, width: maxcount, height: maxcount), mandelbrotRect: mandelbrotRect)
                
                zs2[Int(x) * (maxcount + 1 ) + Int(y)] = SIMD4<Float>(zs[Int(x)][Int(y)].real, zs[Int(x)][Int(y)].imag, 0.0, 0.0)
            }
        }
        
        //let inVectorBufferNoCopy = device.makeBuffer(bytes: zs2, length: byteCount, options: [])!
        
        //let minimumLinearTextureAlignment = device.minimumLinearTextureAlignment(for: textureDescriptor.pixelFormat)
        
        let bytesPerRow = textureDescriptor.width * MemoryLayout<SIMD4<Float>>.stride
        inputTexture = device.makeTexture(descriptor: textureDescriptor)!
        
        let region = MTLRegion(origin: MTLOriginMake(0, 0, 0), size: MTLSizeMake(textureDescriptor.width, textureDescriptor.height, 1))
        
        inputTexture.replace(region: region, mipmapLevel: 0, withBytes: zs2, bytesPerRow: bytesPerRow)
        //print("inputTexture = \(inputTexture)")
        
        let pixelBytes = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<SIMD4<Float>>.stride * textureDescriptor.width * textureDescriptor.height, alignment: MemoryLayout<SIMD4<Float>>.stride)
        
        inputTexture.getBytes(pixelBytes, bytesPerRow:bytesPerRow, from: region, mipmapLevel: 0)
        
        //computeCommandEncoder.setBuffer(inVectorBufferNoCopy, offset: 0, index: 0)
        computeCommandEncoder.setTexture(inputTexture, index: 0)
        
        textureDescriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.shaderRead.rawValue)
        outputTexture = device.makeTexture(descriptor: textureDescriptor)!
        
        computeCommandEncoder.setTexture(outputTexture, index: 1)
        
        outmemory = Array(repeating: [UInt8](repeating: 0, count: maxcount + 1), count: maxcount + 1)
        
        //let outVectorBufferNoCopy = device.makeBuffer(bytes: outmemory, length: numCount * MemoryLayout<UInt8>.stride, options: [])!
        //computeCommandEncoder.setBuffer(outVectorBufferNoCopy, offset: 0, index: 1)
        
        print("computePipelineState.maxTotalThreadsPerThreadgroup = \(computePipelineState.maxTotalThreadsPerThreadgroup)")
        print("computePipelineState.threadExecutionWidth = \(computePipelineState.threadExecutionWidth)")
        
        // hardcoded to 32 for now (recommendation: read about threadExecutionWidth)
        let threadWidth = 32
        let numThreadgroups = MTLSize(width: (maxcount + threadWidth) / threadWidth, height: (maxcount + threadWidth) / threadWidth, depth: 1)
        let threadsPerGroup = MTLSize(width: threadWidth, height: threadWidth, depth: 1)
        computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        computeCommandEncoder.endEncoding()
        
        let vertexLength = MemoryLayout<Vertex>.stride * vertices.count
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexLength, options: [])!
    
        let indexLength = MemoryLayout<UInt16>.stride * indexArray.count
        indexBuffer = device.makeBuffer(bytes: indexArray, length: indexLength, options: [])!
    
        let mandelbrotData: [Float] = [mandelbrot.zoom,
                                   Float(mandelbrot.delta.x), Float(mandelbrot.delta.y),
                                   Float(mandelbrot.origin.x), Float(mandelbrot.origin.y)]
        let mandelbrotLength = MemoryLayout<Float>.stride * mandelbrotData.count
        mandelbrotBuffer = device.makeBuffer(bytes: mandelbrotData, length: mandelbrotLength, options: [])!
    
        super.init()
        
        
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
        
        outputTexture.getBytes(data, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
    
        //for k in 0...maxcount {
        //   for l in 0...maxcount {
        //        let offset = (k * (maxcount + 1) + l) * MemoryLayout<SIMD4<Float>>.stride
        //        let offsetPointer = outputBytes.advanced(by: offset)
                
        //        if (offsetPointer.load(as: SIMD4<Float>.self) != SIMD4<Float>(0, 0, 0, 0)) {
        //            print ("offset \(offset): \(offsetPointer.load(as: SIMD4<Float>.self))")
        //        }
        //    }
        //}
        
        
        //let data = outVectorBufferNoCopy.contents()
        //guard let data = outputBytes.contents() else {
        //    print("No data: \(String(describing: outputTexture.buffer?.contents()))")
        //    return
        //}
        
        var imgBytes = [PixelData](repeating: PixelData(a: 255, r: 0, g: 0, b: 0), count: numCount)
        //var imgBytes = [PixelData]()
        let maxIter = 200
        
        var n = 0
        var n_maxIter = 0
        var max_colorValue: UInt8 = 0
        
        //for k in 0..<numCount {
        for k in 0...maxcount {
            for l in 0...maxcount {
                let offset = (k * (maxcount + 1) + l) * MemoryLayout<SIMD4<Float>>.stride
                
                //let offset = k * MemoryLayout<SIMD4<Float>>.stride
                let offsetPointer = data.advanced(by: offset)
                let value = Int(offsetPointer.load(as: SIMD4<Float>.self).x)
            
                //print("k = \(k), value = \(value)")
            
                if (value > 0) {
                    n = n + 1
                    if (value == maxIter) {
                        n_maxIter = n_maxIter + 1
                    }
                }
            
                if (max_colorValue < value) {
                    max_colorValue = UInt8(value)
                }
                imgBytes[(k * (maxcount + 1) + l)] = PixelData(a: UInt8(255), r: UInt8(0), g: UInt8(value), b: UInt8(0))
            }
        }
        
        
        print("n = \(n)")
        print("n_maxIter = \(n_maxIter)")
        print("max_colorValue = \(max_colorValue)")
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent: Int = 8
        let bitsPerPixel: Int = 32
        
        let imgData = NSData(bytes: imgBytes, length: imgBytes.count * MemoryLayout<PixelData>.size)
        //let imgData = NSData(bytes: data, length: numCount * MemoryLayout<SIMD4<Float>>.size)
        let providerRef = CGDataProvider(data: imgData)!
        
        //let offset1 = (50 * (maxcount + 1) + 149) * MemoryLayout<SIMD4<Float>>.stride
        //let offset2 = (50 * (maxcount + 1) + 149) * MemoryLayout<PixelData>.stride
        
        //print("pixelBytes = \(pixelBytes.advanced(by: offset1).load(as: SIMD4<Float>.self))")
        //print("outputBytes = \(data.advanced(by: offset1).load(as: SIMD4<Float>.self))")
        //print("imgBytes = \(imgBytes[(50 * (maxcount + 1) + 149)].g)")
        //print("imgData = \(imgData.bytes.advanced(by: offset2).load(as: PixelData.self))")
        
        let cgim = CGImage(
            width: maxcount + 1,
            height: maxcount + 1,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: (maxcount + 1) * MemoryLayout<PixelData>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        )
        
        mandelbrotImage = NSImage(cgImage: cgim!, size: NSSize.zero)
    }
  
    static func createPipelineState() -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    
        // pipeline state properties
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
        let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
    
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
    }

    static func viewCoordinatesToComplexCoordinates(x: Float, y: Float, rect: CGRect, mandelbrotRect: ComplexRect) -> MandelbrotComplex {
        let rectScale: CGFloat = 1.0
        let diag = mandelbrotRect.bottomRight - mandelbrotRect.topLeft
        
        let zx = Float(mandelbrotRect.topLeft.real) + ( x / Float(rect.size.width * rectScale) ) * Float(diag.real)
        let zy = Float(mandelbrotRect.topLeft.imaginary) + ( y / Float(rect.size.height * rectScale) ) * Float(diag.imaginary)
        return MandelbrotComplex(real: zx, imag: zy)
    }

    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    
    }
  
    func draw(in view: MTKView) {
//        guard let commandBuffer = commandQueue.makeCommandBuffer(),
//            let drawable = view.currentDrawable,
//            let descriptor = view.currentRenderPassDescriptor,
//            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
//                return
//
//        }
        
        //guard let commandBuffer = commandQueue.makeCommandBuffer(),
        //    let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
        //        return
        //}
        
        //computeCommandEncoder.setComputePipelineState(computePipelineState)
        
        //computeCommandEncoder.setTexture(inputTexture, index: 0)
        //computeCommandEncoder.setTexture(outputTexture, index: 1)
        
        //let region = MTLRegion(origin: MTLOriginMake(0, 0, 0), size: MTLSizeMake(textureDescriptor.width, textureDescriptor.height, 1))
        //let bytesPerRow = textureDescriptor.width * MemoryLayout<SIMD4<Float>>.stride
        
        //let outputBytes = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<SIMD4<Float>>.stride * textureDescriptor.width * textureDescriptor.height, alignment: MemoryLayout<SIMD4<Float>>.stride)
        
        //let offset = (textureDescriptor.height - 1)
        //outputTexture.getBytes(outputBytes, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
        //print("outputBytes = \(outputBytes.load(as: SIMD4<Float>.self))")
        //print("outputBytes = \(outputBytes.advanced(by: MemoryLayout<SIMD4<Float>>.stride * textureDescriptor.width).load(as: SIMD4<Float>.self))")
        //print("outputBytes = \(outputBytes.advanced(by: MemoryLayout<SIMD4<Float>>.stride * offset).load(as: SIMD4<Float>.self))")
        
        
        //commandBuffer.commit()
            
        //commandBuffer.waitUntilCompleted()
        
        //print("outputTexture = \(outputTexture)")
        
        
        //let pixelBytes = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<SIMD4<Float>>.stride * textureDescriptor.width * textureDescriptor.height, alignment: MemoryLayout<SIMD4<Float>>.stride)
        
        //inputTexture.getBytes(pixelBytes, bytesPerRow:bytesPerRow, from: region, mipmapLevel: 0)
        
        //print("pixelBytes = \(pixelBytes.load(as: SIMD4<Float>.self))")
        //print("pixelBytes = \(pixelBytes.advanced(by: MemoryLayout<SIMD4<Float>>.stride * textureDescriptor.width).load(as: SIMD4<Float>.self))")
        //print("pixelBytes = \(pixelBytes.advanced(by: MemoryLayout<SIMD4<Float>>.stride * offset).load(as: SIMD4<Float>.self))")
        
        //outputTexture.getBytes(outputBytes, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
       
        
        //print("outputBytes = \(outputBytes.load(as: SIMD4<Float>.self))")
        //print("outputBytes = \(outputBytes.advanced(by: MemoryLayout<SIMD4<Float>>.stride * textureDescriptor.width).load(as: SIMD4<Float>.self))")
        //print("outputBytes = \(outputBytes.advanced(by: MemoryLayout<SIMD4<Float>>.stride * offset).load(as: SIMD4<Float>.self))")
        
        //print("outputBytes = \(outputBytes.load(as: SIMD4<Float>.self))")
//
//        commandEncoder.setRenderPipelineState(pipelineState)
//
//        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//    
//        commandEncoder.setFragmentBuffer(mandelbrotBuffer, offset: 0, index: 0)
//
//        // draw call
//        commandEncoder.drawIndexedPrimitives(type: .triangle,
//                                             indexCount: indexArray.count,
//                                             indexType: .uint16,
//                                             indexBuffer: indexBuffer,
//                                             indexBufferOffset: 0)
//
//
//        commandEncoder.endEncoding()
//
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//
    }
}

extension MTLVertexDescriptor {
    static func defaultVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
    
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
    
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
    
        return vertexDescriptor
    }
}
