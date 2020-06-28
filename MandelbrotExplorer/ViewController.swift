//
//  ViewController.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    @IBOutlet weak var defaultMandelbrotView: MandelbrotView!
    @IBOutlet weak var mandelbrotView: ZoomedMandelbrotView!
    
    @IBOutlet weak var zoomedMandelbrotImageView: NSImageView!
    @IBOutlet weak var mandelbrotMTKView: MTKView!
    
    let sideLength = 383
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let defualtMandelbrotRect = ComplexRect(Complex(-2.1, -1.5), Complex(0.9, 1.5))
    
    //var zs: [Complex]!
    var mandelbrotSet: MandelbrotSet?
    
    var defaultMandelbrotDisplay: MandelbrotDisplay?
    var mandelbrotDisplay: MandelbrotDisplay?
    var zoomedMandelbrotDisplay: MandelbrotDisplay?
    
    var renderer: Renderer?
    var zoomedMandelbrotRect: ComplexRect?
    var zoomedMandelbrotRect2: ComplexRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let startTime = Date()
        
        displayDefaultMandelbrotSet()
        
        defaultMandelbrotView.delegate = self
        
        print("Elapsed time: \(Date().timeIntervalSince(startTime)) seconds")
        
        displayMandelbrotSet()
        
        mandelbrotView.delegate = self
        
        displayZoomedMandelbrotSet()
        
        renderer = Renderer(view: mandelbrotMTKView)
        mandelbrotMTKView.device = Renderer.device
        mandelbrotMTKView.delegate = renderer
        
        mandelbrotMTKView.clearColor = MTLClearColor(red: 1.0,
                                             green: 1.0,
                                             blue: 0.8,
                                             alpha: 1.0)
        
        print("METAL Elapsed time: \(Date().timeIntervalSince(startTime)) seconds")
        
        //if (renderer?.mandelbrotImage != nil) {
            //print("renderer?.mandelbrotImage = \(String(describing: renderer?.mandelbrotImage))")
           // zoomedMandelbrotImageView.image = renderer?.mandelbrotImage
        //}
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func displayDefaultMandelbrotSet() -> Void {
        defaultMandelbrotDisplay = MandelbrotDisplay(sideLength: sideLength)
        defaultMandelbrotDisplay?.mandelbrotRect = defualtMandelbrotRect
        //defaultMandelbrotDisplay?.setMandelbrotRect(realOrigin: -2.1, imaginrayOrigin: -1.5, realRange: 3.0, imaginaryRange: 3.0)
        defaultMandelbrotDisplay?.generateMandelbrotSet()
        defaultMandelbrotView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
    }
    
    func displayMandelbrotSet() -> Void {
        mandelbrotDisplay = MandelbrotDisplay(sideLength: sideLength)
        
        defaultMandelbrotDisplay?.child = mandelbrotDisplay
        defaultMandelbrotDisplay?.updateChild(rect: defaultMandelbrotView.selectRect)
        
        mandelbrotView.mandelbrotImage = mandelbrotDisplay?.mandelbrotImage
    }
    
    func displayZoomedMandelbrotSet() -> Void {
        zoomedMandelbrotDisplay = MandelbrotDisplay(sideLength: sideLength)
        
        mandelbrotDisplay?.child = zoomedMandelbrotDisplay
        mandelbrotDisplay?.updateChild(rect: mandelbrotView.selectRect)
        
        zoomedMandelbrotImageView.image = zoomedMandelbrotDisplay?.mandelbrotImage
    }
    
    func updateZoomedMandelbrotSet() -> Void {
        guard let zoomedMandelbrotRect = zoomedMandelbrotRect else {
            return
        }
        
        mandelbrotDisplay?.mandelbrotRect =  zoomedMandelbrotRect
        mandelbrotDisplay?.generateMandelbrotSet()
        
        mandelbrotView.mandelbrotImage = mandelbrotDisplay?.mandelbrotImage
        
    }
    
    func updateZoomedMandelbrotSet2() -> Void {
        guard let zoomedMandelbrotRect = zoomedMandelbrotRect2 else {
            return
        }
        
        zoomedMandelbrotDisplay?.mandelbrotRect =  zoomedMandelbrotRect
        zoomedMandelbrotDisplay?.generateMandelbrotSet()
        
        zoomedMandelbrotImageView.image = zoomedMandelbrotDisplay?.mandelbrotImage
        
    }
    
    func viewCoordinatesToComplexCoordinates(x: Double, y: Double, displaySize: CGSize, in complexRect: ComplexRect) -> Complex {
        let minReal = complexRect.minReal
        let maxReal = complexRect.maxReal
        let minImaginary = complexRect.minImaginary
        let maxImaginary = complexRect.maxImaginary
        
        let r = minReal + ( x / Double(displaySize.width) ) * (maxReal - minReal)
        let i = minImaginary + ( y / Double(displaySize.height) ) * (maxImaginary - minImaginary)
        return Complex(r, i)
    }
}

extension ViewController: MandelbrotViewDelegate {
    func update(rect: CGRect) {
        let tl = viewCoordinatesToComplexCoordinates(x: Double(rect.minX), y: Double(rect.minY), displaySize: CGSize(width: sideLength, height: sideLength), in: defualtMandelbrotRect)
        let br = viewCoordinatesToComplexCoordinates(x: Double(rect.maxX), y: Double(rect.maxY), displaySize: CGSize(width: sideLength, height: sideLength), in: defualtMandelbrotRect)
        
        //print("rect = \(rect)")
        //print("tl = \(tl)")
        //print("br = \(br)")
        
        zoomedMandelbrotRect = ComplexRect(tl, br)
        
        //updateZoomedMandelbrotSet()
        
        defaultMandelbrotDisplay?.updateChild(rect: rect)
        mandelbrotView.mandelbrotImage = mandelbrotDisplay?.mandelbrotImage
        
        mandelbrotView.mandelbrotRect = mandelbrotDisplay!.mandelbrotRect
        mandelbrotView.rectScale = (defualtMandelbrotRect.maxReal - defualtMandelbrotRect.minReal) / (mandelbrotView.mandelbrotRect.maxReal - mandelbrotView.mandelbrotRect.minReal)
        
        let rect2 = mandelbrotView.selectRect
        
        let tl2 = viewCoordinatesToComplexCoordinates(x: Double(rect2.minX), y: Double(rect2.minY), displaySize: CGSize(width: sideLength, height: sideLength), in: mandelbrotView.mandelbrotRect)
        let br2 = viewCoordinatesToComplexCoordinates(x: Double(rect2.maxX), y: Double(rect2.maxY), displaySize: CGSize(width: sideLength, height: sideLength), in: mandelbrotView.mandelbrotRect)
        
        zoomedMandelbrotRect2 = ComplexRect(tl2, br2)
        
        updateZoomedMandelbrotSet2()
        
    }
}

extension ViewController: ZoomedMandelbrotViewDelegate {
    func updateZoomed(rect: CGRect) {
        print("ZoomedMandelbrotViewDelegate.updateZoomed() :: \(mandelbrotView.selectRect)")
    
        let tl = viewCoordinatesToComplexCoordinates(x: Double(rect.minX), y: Double(rect.minY), displaySize: CGSize(width: sideLength, height: sideLength), in: mandelbrotView.mandelbrotRect)
        let br = viewCoordinatesToComplexCoordinates(x: Double(rect.maxX), y: Double(rect.maxY), displaySize: CGSize(width: sideLength, height: sideLength), in: mandelbrotView.mandelbrotRect)
        
        //print("rect = \(rect)")
        //print("tl = \(tl)")
        //print("br = \(br)")
        
        zoomedMandelbrotRect2 = ComplexRect(tl, br)
        
        mandelbrotDisplay?.updateChild(rect: rect)
        
        zoomedMandelbrotImageView.image = zoomedMandelbrotDisplay?.mandelbrotImage
        
        //updateZoomedMandelbrotSet2()
        
    }
}
