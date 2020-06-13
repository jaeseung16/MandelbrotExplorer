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
    @IBOutlet weak var mandelbrotView: AnotherMandelbrotView!
    
    @IBOutlet weak var zoomedMandelbrotImageView: NSImageView!
    @IBOutlet weak var mandelbrotMTKView: MTKView!
    
    let sideLength = 300
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let defualtMandelbrotRect = ComplexRect(Complex(-1.5, -0.5), Complex(-0.5, 0.5))
    
    //var zs: [Complex]!
    var mandelbrotSet: MandelbrotSet?
    
    var defaultMandelbrotDisplay: MandelbrotDisplay?
    var mandelbrotDisplay: MandelbrotDisplay?
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let startTime = Date()
        
        displayDefaultMandelbrotSet()
        
        mandelbrotDisplay = MandelbrotDisplay(sideLength: sideLength)
        mandelbrotDisplay?.setMandelbrotRect(realOrigin: -1.5, imaginrayOrigin: -0.5, realRange: 1.0, imaginaryRange: 1.0)
        
        zoomedMandelbrotImageView.image = mandelbrotDisplay?.mandelbrotImage
        
        print("Elapsed time: \(Date().timeIntervalSince(startTime)) seconds")
        
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
            zoomedMandelbrotImageView.image = renderer?.mandelbrotImage
        //}
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func displayDefaultMandelbrotSet() -> Void {
        defaultMandelbrotDisplay = MandelbrotDisplay(sideLength: sideLength)
        defaultMandelbrotDisplay?.setMandelbrotRect(realOrigin: -2.1, imaginrayOrigin: -1.5, realRange: 3.0, imaginaryRange: 3.0)
        defaultMandelbrotDisplay?.generateMandelbrotSet()
        defaultMandelbrotView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
    }
    
}

