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
    private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    private let bitsPerComponent: Int = 8
    private let bitsPerPixel: Int = 32
    
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
    var cgColors: [CGColor]?
    
    init(cgColor: CGColor) {
        self.cgColor = cgColor
    }
    
    init(cgColors: [CGColor]) {
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
        var imgBytes = [SIMD4<UInt8>](repeating: SIMD4<UInt8>(x: 0, y: 0, z: 0, w: 255), count: values.count)
        
        for x in 0..<lengthOfRow {
            for y in 0..<lengthOfRow {
                let value = values[y * lengthOfRow + x]
                
                let color = cgColors?[value] ?? cgColor
                let colorSIMD4 = color!.components!.map { UInt8($0 * CGFloat(value)) }
                
                imgBytes[(lengthOfRow - y - 1) * lengthOfRow + x] = SIMD4<UInt8>(x: colorSIMD4[0], y: colorSIMD4[1], z: colorSIMD4[2], w: UInt8(color!.alpha * CGFloat(UInt8.max)))
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
