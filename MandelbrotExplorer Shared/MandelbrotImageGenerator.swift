//
//  MandelbrotImageGenerator.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 10/8/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreImage

class MandelbrotImageGenerator {
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue:  CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue | CGBitmapInfo.floatComponents.rawValue)
    private let bitsPerComponent: Int = 32
    private let bitsPerPixel: Int = 128
    
    private var _cgImage: CGImage?
    var cgImage: CGImage {
        get {
            return _cgImage!
        }
        set {
            _cgImage = newValue;
        }
    }
    
    var cgColor: CGColor?
    var cgColors: [SIMD4<Float>]?
    
    init(cgColor: CGColor) {
        self.cgColor = cgColor
    }
    
    init(cgColors: [SIMD4<Float>]) {
        self.cgColors = cgColors
    }
    
    private func generateCGImage(from mtlTexture: MTLTexture) -> Void {
        let ciImageOptions: [CIImageOption: Any] = [.colorSpace: CGColorSpaceCreateDeviceRGB()]
        let ciImage = CIImage(mtlTexture: mtlTexture, options: ciImageOptions)!
        
        let contextOptions: [CIContextOption: Any] = [.outputPremultiplied: true,
                              .useSoftwareRenderer: false]
        let context = CIContext(options: contextOptions)
        
        cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
    }
    
    func generateCGImage(values: [Int], lengthOfRow: Int) -> Void {
        var imgBytes = [SIMD4<Float>](repeating: SIMD4<Float>(x: 0.0, y: 0.0, z: 0.0, w: 1.0), count: values.count)
        
        //print("cgColors = \(cgColors)")
        
        for x in 0..<lengthOfRow {
            for y in 0..<lengthOfRow {
                let index = values[y * lengthOfRow + x]
                imgBytes[(lengthOfRow - y - 1) * lengthOfRow + x] = cgColors![index]
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
        
        print("bitmapInfo = \(_cgImage!.bitmapInfo)")
    }
}
