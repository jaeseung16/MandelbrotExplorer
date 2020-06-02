//
//  ViewController.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var defaultMandelbrotView: MandelbrotView!
    @IBOutlet weak var zoomedMandelbrotImageView: NSImageView!
    
    @IBOutlet weak var anotherMandelbrotView: AnotherMandelbrotView!
    
    let sideLength = 300
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let mandelbrotRect = ComplexRect(Complex(-1.5, -0.5), Complex(-0.5, 0.5))
    
    //var zs: [Complex]!
    var mandelbrotSet: MandelbrotSet?
    
    var defaultMandelbrotDisplay: MandelbrotDisplay?
    var mandelbrotDisplay: MandelbrotDisplay?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let startTime = Date()
        
        let rect = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
        
        defaultMandelbrotDisplay = MandelbrotDisplay(sideLength: sideLength)
        defaultMandelbrotDisplay?.setMandelbrotRect(realOrigin: -2.1, imaginrayOrigin: -1.5, realRange: 3.0, imaginaryRange: 3.0)
        anotherMandelbrotView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
    
        
        print("Elapsed time: \(Date().timeIntervalSince(startTime)) seconds")
        
        mandelbrotDisplay = MandelbrotDisplay(sideLength: sideLength)
        mandelbrotDisplay?.setMandelbrotRect(realOrigin: -1.5, imaginrayOrigin: -0.5, realRange: 1.0, imaginaryRange: 1.0)
        
        zoomedMandelbrotImageView.image = mandelbrotDisplay?.mandelbrotImage
        
        print("Elapsed time: \(Date().timeIntervalSince(startTime)) seconds")
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

