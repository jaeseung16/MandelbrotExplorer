//
//  ViewController.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Cocoa
import MetalKit
import ComplexModule

class ViewController: NSViewController {

    @IBOutlet weak var defaultMandelbrotView: MandelbrotView!
    @IBOutlet weak var mandelbrotView: MandelbrotView!
    @IBOutlet weak var zoomedMandelbrotView: MandelbrotView!
    
    @IBOutlet weak var mandelbrotMTKView: MTKView!
    
    let sideLength = 1023 //383
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let defaultMandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    
    //var zs: [Complex]!
    var mandelbrotSet: MandelbrotSet?
    
    var defaultMandelbrotDisplay: MandelbrotDisplay?
    var mandelbrotDisplay: MandelbrotDisplay?
    var zoomedMandelbrotDisplay: MandelbrotDisplay?
    
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let startTime = Date()
        
        initializeDefaultMandelbrotDisplay()
        
        initializeDefaultMandelbrotView()
        
        print("Elapsed time: \(Date().timeIntervalSince(startTime)) seconds")
        
        initializeMandelbrotDisplay()
        
        initializeMandelbrotView()
        
        print("Elapsed time: \(Date().timeIntervalSince(startTime)) seconds")
        
        initializeZoomedMandelbrotDisplay()
        
        initializeZoomedMandelbrotView()
        
        print("Elapsed time: \(Date().timeIntervalSince(startTime)) seconds")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func initializeMKTView() -> Void {
        renderer = Renderer(view: mandelbrotMTKView)
        mandelbrotMTKView.device = Renderer.device
        mandelbrotMTKView.delegate = renderer
        
        mandelbrotMTKView.clearColor = MTLClearColor(red: 1.0,
                                             green: 1.0,
                                             blue: 0.8,
                                             alpha: 1.0)
        
        //print("METAL Elapsed time: \(Date().timeIntervalSince(startTime)) seconds")
        
        //if (renderer?.mandelbrotImage != nil) {
            //print("renderer?.mandelbrotImage = \(String(describing: renderer?.mandelbrotImage))")
           // zoomedMandelbrotImageView.image = renderer?.mandelbrotImage
        //}
    }
    
    func initializeDefaultMandelbrotDisplay() -> Void {
        defaultMandelbrotDisplay = MandelbrotDisplay(sideLength: sideLength)
        defaultMandelbrotDisplay?.id = MandelbrotID.first
        defaultMandelbrotDisplay?.mandelbrotRect = defaultMandelbrotRect
        defaultMandelbrotDisplay?.generateMandelbrotSet()
    }
    
    func initializeDefaultMandelbrotView() -> Void {
        defaultMandelbrotView.delegate = self
        defaultMandelbrotView.id = MandelbrotID.first
        defaultMandelbrotView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
        defaultMandelbrotView.selectRect = CGRect(x: 70, y: 176, width: 32, height: 32)
        defaultMandelbrotView.mandelbrotRect = defaultMandelbrotRect
        defaultMandelbrotView.rectScale = 1.0
    }
    
    func initializeMandelbrotDisplay() -> Void {
        mandelbrotDisplay = MandelbrotDisplay(sideLength: sideLength)
        mandelbrotDisplay?.id = MandelbrotID.second
        
        defaultMandelbrotDisplay?.child = mandelbrotDisplay
        defaultMandelbrotDisplay?.updateChild(rect: defaultMandelbrotView.selectRect!)
    }
    
    func initializeMandelbrotView() -> Void {
        mandelbrotView.delegate = self
        mandelbrotView.id = MandelbrotID.second
        mandelbrotView.selectRect = CGRect(x: 70, y: 176, width: 32, height: 32)
        
        update(mandelbrotView: mandelbrotView, with: mandelbrotDisplay!)
    }
    
    
    func initializeZoomedMandelbrotDisplay() -> Void {
        zoomedMandelbrotDisplay = MandelbrotDisplay(sideLength: sideLength)
        defaultMandelbrotDisplay?.id = MandelbrotID.third
        
        mandelbrotDisplay?.child = zoomedMandelbrotDisplay
        mandelbrotDisplay?.updateChild(rect: mandelbrotView.selectRect!)
    }
    
    func initializeZoomedMandelbrotView() -> Void {
        zoomedMandelbrotView.id = MandelbrotID.third
        update(mandelbrotView: zoomedMandelbrotView, with: zoomedMandelbrotDisplay!)
    }
    
    func update(mandelbrotView: MandelbrotView, with mandelbrotDisplay: MandelbrotDisplay) -> Void {
        mandelbrotView.mandelbrotImage = mandelbrotDisplay.mandelbrotImage
        mandelbrotView.mandelbrotRect = mandelbrotDisplay.mandelbrotRect
        mandelbrotView.rectScale = (defaultMandelbrotRect.maxReal - defaultMandelbrotRect.minReal) / (mandelbrotView.mandelbrotRect.maxReal - mandelbrotView.mandelbrotRect.minReal)
    }
    
    func viewCoordinatesToComplexCoordinates(x: Double, y: Double, displaySize: CGSize, in complexRect: ComplexRect) -> Complex<Double> {
        let minReal = complexRect.minReal
        let maxReal = complexRect.maxReal
        let minImaginary = complexRect.minImaginary
        let maxImaginary = complexRect.maxImaginary
        
        let r = minReal + ( x / Double(displaySize.width) ) * (maxReal - minReal)
        let i = minImaginary + ( y / Double(displaySize.height) ) * (maxImaginary - minImaginary)
        return Complex<Double>(r, i)
    }
    
    @IBAction func savePDF(_ sender: NSButton) {
        guard let cgImage = defaultMandelbrotDisplay?.mandelbrotSet?.cgImage else {
            print("There is no image to generate a pdf file.")
            return
        }
        /*        let url = URL(fileURLWithPath: "mandelbrot1024.pdf")
        let dc = CGDataConsumer(url: url as CFURL)
        let dest = CGImageDestinationCreateWithDataConsumer(dc!, kUTTypePDF, 1, nil)
        
        CGImageDestinationAddImage(dest!, cgImage, nil)
        CGImageDestinationFinalize(dest!)
        */
        
        let url = URL(fileURLWithPath: "mandelbrot1024.png")
        let dc = CGDataConsumer(url: url as CFURL)
        let dest = CGImageDestinationCreateWithDataConsumer(dc!, kUTTypePNG, 1, nil)
        CGImageDestinationAddImage(dest!, cgImage, nil)
        CGImageDestinationFinalize(dest!)
    }
    
}

extension ViewController: MandelbrotViewDelegate {
    func update(rect: CGRect, in id: MandelbrotID) {
        if (id == MandelbrotID.first) {
            defaultMandelbrotDisplay?.updateChild(rect: rect)
            update(mandelbrotView: mandelbrotView, with: mandelbrotDisplay!)
        }
        
        if (id == MandelbrotID.first || id == MandelbrotID.second) {
            mandelbrotDisplay?.updateChild(rect: mandelbrotView.selectRect!)
            update(mandelbrotView: zoomedMandelbrotView, with: zoomedMandelbrotDisplay!)
        }
        
    }
}
