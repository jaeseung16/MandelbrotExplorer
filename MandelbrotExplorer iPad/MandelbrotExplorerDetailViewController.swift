//
//  ViewController.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/4/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import UIKit
import ComplexModule

class MandelbrotExplorerDetailViewController: UIViewController {

    @IBOutlet weak var mandelbrotUIView: MandelbrotUIView!
    @IBOutlet weak var zoomedMandelbrotUIView: MandelbrotUIView!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    var defaultMandelbrotDisplay: MandelbrotDisplayIPad?
    var zoomedMandelbrotDisplay: MandelbrotDisplayIPad?
    
    let sideLength = 383
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let defaultMandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    var zoomedMandelbrotRect: ComplexRect?
    
    var mandelbrotImageGenerator: MandelbrotImageGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initializeDefaultMandelbrotDisplay()
        
        initializeDefaultMandelbrotView()
        
        initializeZoomedMandelbrotDisplay()
        
        initializeZoomedMandelbrotView()
        
    }

    func initializeDefaultMandelbrotDisplay() {
        defaultMandelbrotDisplay = MandelbrotDisplayIPad(sideLength: sideLength)
        defaultMandelbrotDisplay?.color = SIMD4<Float>(x: 0.0, y: 1.0, z: 0.0, w: 1.0)
        defaultMandelbrotDisplay?.id = MandelbrotID.first
        defaultMandelbrotDisplay?.mandelbrotRect = defaultMandelbrotRect
        defaultMandelbrotDisplay?.generateMandelbrotSet()
    }
    
    func initializeDefaultMandelbrotView() {
        mandelbrotUIView.delegate = self
        mandelbrotUIView.id = MandelbrotID.first
        mandelbrotUIView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
        mandelbrotUIView.selectRect = CGRect(x: 70, y: 176, width: 32, height: 32)
        mandelbrotUIView.mandelbrotRect = defaultMandelbrotRect
        mandelbrotUIView.rectScale = 1.0
    }
    
    func initializeZoomedMandelbrotDisplay() -> Void {
        zoomedMandelbrotDisplay = MandelbrotDisplayIPad(sideLength: sideLength)
        zoomedMandelbrotDisplay?.color = SIMD4<Float>(x: 0.0, y: 1.0, z: 0.0, w: 1.0)
        zoomedMandelbrotDisplay?.id = MandelbrotID.second
        
        defaultMandelbrotDisplay?.child = zoomedMandelbrotDisplay
        defaultMandelbrotDisplay?.updateChild(rect: mandelbrotUIView.selectRect)
    }
    
    func initializeZoomedMandelbrotView() -> Void {
        zoomedMandelbrotUIView.delegate = self
        zoomedMandelbrotUIView.id = MandelbrotID.second
        //zoomedMandelbrotUIView.selectRect = CGRect(x: 70, y: 176, width: 32, height: 32)
        
        update(mandelbrotUIView: zoomedMandelbrotUIView, with: zoomedMandelbrotDisplay!)
    }
    
    func update(mandelbrotUIView: MandelbrotUIView, with mandelbrotDisplayIPad: MandelbrotDisplayIPad) -> Void {
        mandelbrotUIView.mandelbrotImage = mandelbrotDisplayIPad.mandelbrotImage
        mandelbrotUIView.mandelbrotRect = mandelbrotDisplayIPad.mandelbrotRect
        mandelbrotUIView.rectScale = (defaultMandelbrotRect.maxReal - defaultMandelbrotRect.minReal) / (mandelbrotUIView.mandelbrotRect.maxReal - mandelbrotUIView.mandelbrotRect.minReal)
    }
    
    
    @IBAction func refreshColor(_ sender: UIButton) {
        defaultMandelbrotDisplay?.color = SIMD4<Float>(x: redSlider.value, y: greenSlider.value, z: blueSlider.value, w: 1.0)
        defaultMandelbrotDisplay?.colorMap = nil
        defaultMandelbrotDisplay?.generateMandelbrotSet()
        mandelbrotUIView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
    }
    
    @IBAction func reset(_ sender: UIBarButtonItem) {
        mandelbrotUIView.selectRect = CGRect(x: 70, y: 176, width: 32, height: 32)
        
        defaultMandelbrotDisplay?.updateChild(rect: mandelbrotUIView.selectRect)
        
        update(mandelbrotUIView: zoomedMandelbrotUIView, with: zoomedMandelbrotDisplay!)
    }
    
    @IBAction func refreshColorWithParula256(_ sender: UIButton) {
        defaultMandelbrotDisplay?.colorMap = Parula256.colorsInSIMD4
        defaultMandelbrotDisplay?.color = nil
        defaultMandelbrotDisplay?.generateMandelbrotSet()
        mandelbrotUIView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
    }
    
}

extension MandelbrotExplorerDetailViewController: MandelbrotViewDelegate {
    func update(rect: CGRect, in id: MandelbrotID) {
        if (id == MandelbrotID.first) {
            defaultMandelbrotDisplay?.updateChild(rect: rect)
            update(mandelbrotUIView: zoomedMandelbrotUIView, with: zoomedMandelbrotDisplay!)
        }
    }
}

