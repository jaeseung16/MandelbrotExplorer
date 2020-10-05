//
//  MandelbrotSetCPU.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/14/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import CoreGraphics

class MandelbrotSetCPU: MandelbrotSet {
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    private let bitsPerComponent: Int = 8
    private let bitsPerPixel: Int = 32
    
    private var _zs: [Complex]
    var zs: [Complex] {
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
    
    var imgBytes: [SIMD4<UInt8>]
    
    init(inZs: [Complex], inMaxIter: Int) {
        _zs = inZs
        _maxIter = inMaxIter
        _values = [Int](repeating: 0, count: _zs.count)
        imgBytes = [SIMD4<UInt8>](repeating: SIMD4<UInt8>(x: 0, y: 0, z: 0, w: 255), count: _zs.count)

        calculate()
        generateCGImage(lengthOfRow: Int(sqrt(Double(values.count))))
    }
    
    func calculate() -> Void {
        values = zs.map({ (z0) -> Int in
            mandelbrotFormula(z0: z0)
        })
    }
    
    private func mandelbrotFormula(z0: Complex) -> Int {
        var z = z0
        var iter = 0;
        while (iter < maxIter)
        {
            if (Complex.abs(lhs: z) > 2.0) {
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
                let value = values[y * lengthOfRow + x]
                imgBytes[(lengthOfRow - y - 1) * lengthOfRow + x] = SIMD4<UInt8>(x: UInt8(0), y: UInt8(value), z: UInt8(0), w: UInt8(255))
            }
        }
        
        let imgData = NSData(bytes: &imgBytes, length: imgBytes.count * MemoryLayout<SIMD4<UInt8>>.size)
        let providerRef = CGDataProvider(data: imgData)
        
        _cgImage = CGImage(width: lengthOfRow,
                           height: lengthOfRow,
                           bitsPerComponent: bitsPerComponent,
                           bitsPerPixel: bitsPerPixel,
                           bytesPerRow: lengthOfRow * MemoryLayout<SIMD4<UInt8>>.size,
                           space: rgbColorSpace,
                           bitmapInfo: bitmapInfo,
                           provider: providerRef!,
                           decode: nil,
                           shouldInterpolate: true,
                           intent: CGColorRenderingIntent.defaultIntent)
    }
}
