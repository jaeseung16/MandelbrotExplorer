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
    var child: MandelbrotDisplay?
    
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
    
    var id: MandelbrotID?
    
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
                zs[(sideLength - y - 1) * sideLength + x] = viewCoordinatesToComplexCoordinates(x: Double(x), y: Double(y), displaySize: displaySize)
            }
        }
        
        let timeToPrepare = Date()
        
        mandelbrotSet = MandelbrotSetGPU(inZs: zs, inMaxIter: 200)
        
        let timeToCalculate = Date()
        
        setImage(for: mandelbrotSet)
        
        let timeToSetImage = Date()
            
        print("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToPrepare.timeIntervalSince(startTime)) seconds to populate inputs")
        
        print("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToCalculate.timeIntervalSince(timeToPrepare)) seconds to generate mandelbrotSet")
            
        print("MandelbrotDisplay.generateMandelbrotSet(): It took \(timeToSetImage.timeIntervalSince(timeToCalculate)) seconds")
    }
    
    func viewCoordinatesToComplexCoordinates(x: Double, y: Double, displaySize: CGSize) -> Complex {
        let minReal = mandelbrotRect.minReal
        let maxReal = mandelbrotRect.maxReal
        let minImaginary = mandelbrotRect.minImaginary
        let maxImaginary = mandelbrotRect.maxImaginary
        
        let r = minReal + ( x / Double(displaySize.width) ) * (maxReal - minReal)
        let i = minImaginary + ( y / Double(displaySize.height) ) * (maxImaginary - minImaginary)
        return Complex(r, i)
    }
    
    func viewCoordinatesToComplexCoordinates(x: Double, y: Double, displaySize: CGSize, in complexRect: ComplexRect) -> Complex {
        let minReal = complexRect.minReal
        let maxReal = complexRect.maxReal
        let minImaginary = complexRect.minImaginary
        let maxImaginary = complexRect.maxImaginary
        
        let r = minReal + ( x / Double(displaySize.width) ) * (maxReal - minReal)
        let i = (maxImaginary - minImaginary) / 2.0 - ( y / Double(displaySize.height) ) * (maxImaginary - minImaginary)
        return Complex(r, i)
    }
    
    func updateChild(rect: CGRect) {
        guard let child = child else {
            return
        }
        
        let tl = viewCoordinatesToComplexCoordinates(x: Double(rect.minX), y: Double(rect.minY), displaySize: CGSize(width: sideLength, height: sideLength))
        let br = viewCoordinatesToComplexCoordinates(x: Double(rect.maxX), y: Double(rect.maxY), displaySize: CGSize(width: sideLength, height: sideLength))
        
        child.mandelbrotRect = ComplexRect(tl, br)
        child.generateMandelbrotSet()
        
    }
    
    func setImage(for mandelbrotSet: MandelbrotSet?) -> Void {
        guard let mandelbrotSet = self.mandelbrotSet else {
            print("self.mandelbrotSet is null")
            return
        }
        
        imgBytes = mandelbrotSet.values.map { (value) -> PixelData in
            PixelData(a: UInt8(255), r: UInt8(0), g: UInt8(value), b: UInt8(0))
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
