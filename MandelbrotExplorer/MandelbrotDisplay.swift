//
//  MandelbrotDisplay.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/29/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import Cocoa

class MandelbrotDisplay {
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    let bitsPerComponent: Int = 8
    let bitsPerPixel: Int = 32
    
    var sideLength: Int
    
    var zs: [Complex]
    var imgBytes: [PixelData]
    
    var mandelbrotRect = ComplexRect(Complex(-2.1, -1.5), Complex(0.9, 1.5))
    var mandelbrotSet: MandelbrotSet?
    var mandelbrotImage: NSImage?
    
    init(sideLength: Int) {
        self.sideLength = sideLength + 1
        let numberOfPixels = self.sideLength * self.sideLength
        
        self.imgBytes = [PixelData](repeating: PixelData(a: 255, r: 0, g: 0, b: 0), count: numberOfPixels)
        self.zs = [Complex](repeating: Complex(), count: numberOfPixels)
    }
    
    func setMandelbrotRect(realOrigin: Double, imaginrayOrigin: Double, realRange: Double, imaginaryRange: Double) {
        mandelbrotRect = ComplexRect(Complex(realOrigin, imaginrayOrigin), Complex(realOrigin + realRange, imaginrayOrigin + imaginaryRange))
    }
    
    func generateMandelbrotSet() -> Void {
        print("MandelbrotDisplay.generateMandelbrotSet() called for \(mandelbrotRect) with sideLength = \(sideLength)")
        
        let startTime = Date()
        
        let displaySize = CGSize(width: sideLength - 1, height: sideLength - 1)
        for x in 0..<sideLength {
            for y in 0..<sideLength {
                zs[x * sideLength + y] = viewCoordinatesToComplexCoordinates(x: Double(x), y: Double(y), displaySize: displaySize)
            }
        }
        
        let timeToPrepare = Date()
        
        mandelbrotSet = MandelbrotSet(inZs: zs, inMaxIter: 50)
        
        let timeToCalculate = Date()
        
        setImage(for: mandelbrotSet)
        
        let timeToSetImage = Date()
            
        print("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToPrepare.timeIntervalSince(startTime)) seconds to populate inputs")
        
        print("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToCalculate.timeIntervalSince(timeToPrepare)) seconds to generate mandelbrotSet")
            
        print("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToSetImage.timeIntervalSince(timeToCalculate)) seconds")
    }
    
    func viewCoordinatesToComplexCoordinates(x: Double, y: Double, displaySize: CGSize) -> Complex {
        let tl = mandelbrotRect.topLeft
        let br = mandelbrotRect.bottomRight
        let r = tl.real + ( x / Double(displaySize.width) ) * (br.real - tl.real)
        let i = tl.imaginary + ( y / Double(displaySize.height) ) * (br.imaginary - tl.imaginary)
        return Complex(r, i)
    }
    
    func setImage(for mandelbrotSet: MandelbrotSet?) -> Void {
        guard let mandelbrotSet = self.mandelbrotSet else {
            print("self.mandelbrotSet is null")
            return
        }
        
        for x in 0..<sideLength {
            for y in 0..<sideLength {
                let index = x * sideLength + y
                let indexTransposed = y * sideLength + x
                imgBytes[indexTransposed] = PixelData(a: UInt8(255), r: UInt8(0), g: UInt8(mandelbrotSet.values[index]), b: UInt8(0))
            }
        }
        
        let imgData = NSData(bytes: &imgBytes, length: imgBytes.count * MemoryLayout<PixelData>.size)
        let providerRef = CGDataProvider(data: imgData)
        
        let cgim = CGImage(
            width: sideLength,
            height: sideLength ,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: sideLength * MemoryLayout<PixelData>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        )
        
        self.mandelbrotImage = NSImage(cgImage: cgim!, size: NSSize.zero)
    }
    
}
