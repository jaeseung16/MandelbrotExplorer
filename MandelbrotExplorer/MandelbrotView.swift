//
//  MandelbrotView.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Cocoa

class MandelbrotView: NSView {
    let mandelbrotRect = ComplexRect(Complex(-2.1, -1.5), Complex(0.9, 1.5))
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 0.5 // pick a value from 0.25 to 5.0
    let colorCount = 2000
    var colorSet : Array<NSColor> = Array()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        NSBezierPath.fill(dirtyRect)
        let startTime = Date()
        drawMandelbrot(rect: dirtyRect)
        print("Elapsed time: \(Date().timeIntervalSince(startTime)) seconds")
    }
    
    func initializeColors() {
        if colorSet.count < 2 {
            colorSet = Array()
            for c in 0...colorCount {
                let c_f = CGFloat(c)
                colorSet.append(NSColor(hue: CGFloat(abs(sin(c_f/30.0))), saturation: 1.0, brightness: c_f/100.0 + 0.8, alpha: 1.0))
            }
        }
    }
    
    func computeMandelbrotPoint(C: Complex) -> NSColor {
        // Calculate whether the point is inside or outside the Mandelbrot set
        // Zn+1 = (Zn)^2 + c -- start with Z0 = 0
        var z = Complex()
        for it in 1...colorCount {
            z = z*z + C
            if Complex.modulus(lhs: z) > 2 {
                return colorSet[it] // bail as soon as the complex number is too big (you're outside the set & it'll go to infinity)
            }
        }
        // Yay, you're inside the set!
        return NSColor.black
    }
    
    func viewCoordinatesToComplexCoordinates(x: Double, y: Double, rect: CGRect) -> Complex {
        let tl = mandelbrotRect.topLeft
        let br = mandelbrotRect.bottomRight
        let r = tl.real + ( x / Double(rect.size.width * rectScale) ) * (br.real - tl.real)
        let i = tl.imaginary + ( y / Double(rect.size.height * rectScale) ) * (br.imaginary - tl.imaginary)
        return Complex(r, i)
    }

    func complexCoordinatesToViewCoordinates(c: Complex, rect: CGRect) -> CGPoint {
        let tl = mandelbrotRect.topLeft
        let br = mandelbrotRect.bottomRight
        let x: CGFloat = CGFloat(c.real - tl.real) / CGFloat(br.real - tl.real) * (rect.size.width * rectScale)
        let y: CGFloat = CGFloat(c.imaginary - tl.imaginary) / CGFloat(br.imaginary - tl.imaginary) * (rect.size.height * rectScale)
        return CGPoint(x: x, y: y)
    }

    func drawMandelbrot(rect: CGRect) {
        let startTime = Date()
        
        let width = rect.size.width
        let height = rect.size.height
        initializeColors()

        /*
        for x in stride(from: 0, through: width, by: blockiness) {
            for y in stride(from: 0, through: height, by: blockiness) {
                let cc = viewCoordinatesToComplexCoordinates(x: Double(x), y: Double(y), rect: rect)
                computeMandelbrotPoint(C: cc).set()
                NSBezierPath.fill(CGRect(x: x, y: y, width: blockiness, height: blockiness))
            }
        }
        */
        
        var zs = [Complex](repeating: Complex(), count: (2 * Int(width) + 1) * (2 * Int(width) + 1))
        
        for x in stride(from: 0, through: Double(width), by: Double(blockiness)) {
            for y in stride(from: 0, through: Double(height), by: Double(blockiness)) {
                zs[(Int)(x * Double(2 * width + 1) + y)] = viewCoordinatesToComplexCoordinates(x: Double(x), y: Double(y), rect: rect)
            }
        }
        
        let mandelbrotSet = MandelbrotSet(inZs: zs, inMaxIter: 50)
        
        print("Calculation time: \(Date().timeIntervalSince(startTime))")
        
        for x in stride(from: 0, through: Double(width), by: Double(blockiness)) {
            for y in stride(from: 0, through: Double(height), by: Double(blockiness)) {
                let index = Int(x * Double(2 * width + 1) + y)
                let color = colorSet[mandelbrotSet.values[index]]
                color.set()
                NSBezierPath.fill(CGRect(x: CGFloat(x), y: CGFloat(y), width: blockiness, height: blockiness))
            }
        }
        
        print("Image Fill time: \(Date().timeIntervalSince(startTime))")
        
    }
    
}
