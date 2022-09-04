//
//  MandelbrotSetCPU.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/14/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import CoreGraphics
import ComplexModule

class MandelbrotSetCPU: MandelbrotSet {
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
    private let bitsPerComponent: Int = 32
    private let bitsPerPixel: Int = 128
    
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
    
    var imgBytes: [SIMD4<Float>]
    var colorMap: [SIMD4<Float>]
    
    init(inZs: [Complex<Double>], inMaxIter: Int, inColorMap: [SIMD4<Float>]) {
        _zs = inZs
        _maxIter = inMaxIter
        _values = [Int](repeating: 0, count: _zs.count)
        imgBytes = [SIMD4<Float>](repeating: SIMD4<Float>(x: 0.0, y: 0.0, z: 0.0, w: 1.0), count: _zs.count)
        colorMap = inColorMap
    }
    
    func calculate(completionHandler: ((CGImage) -> Void)? = nil) -> Void {
        DispatchQueue.concurrentPerform(iterations: zs.count) { k in
            _values[k] = mandelbrotFormula(z0: zs[k])
        }
        
        let mandelbrotImageGenerator = MandelbrotImageGenerator(cgColors: colorMap)
        mandelbrotImageGenerator.generateCGImage(values: values, lengthOfRow: Int(sqrt(Double(values.count))))
        
        cgImage = mandelbrotImageGenerator.cgImage
        
        completionHandler?(cgImage)
        
    }
    
    private func mandelbrotFormula(z0: Complex<Double>) -> Int {
        var z = z0
        var iter = 0;
        while (iter < maxIter)
        {
            if (z.length > 2.0) {
                break
            }
            z = z * z + z0
            iter += 1
        }

        return (maxIter == iter) ? 0 : Int((Float(iter) / Float(maxIter) * 255.0))
    }
    
    private func generateCGImage(lengthOfRow: Int) -> Void {
        for x in 0..<lengthOfRow {
            for y in 0..<lengthOfRow {
                let index = values[y * lengthOfRow + x]
                imgBytes[(lengthOfRow - y - 1) * lengthOfRow + x] = colorMap[index]
            }
        }
        
        let imgData = NSData(bytes: &imgBytes, length: imgBytes.count * MemoryLayout<SIMD4<Float>>.size)
        let providerRef = CGDataProvider(data: imgData)
        
        _cgImage = CGImage(width: lengthOfRow,
                           height: lengthOfRow,
                           bitsPerComponent: bitsPerComponent,
                           bitsPerPixel: bitsPerPixel,
                           bytesPerRow: lengthOfRow * MemoryLayout<SIMD4<Float>>.size,
                           space: rgbColorSpace,
                           bitmapInfo: bitmapInfo,
                           provider: providerRef!,
                           decode: nil,
                           shouldInterpolate: true,
                           intent: CGColorRenderingIntent.defaultIntent)
    }
}
