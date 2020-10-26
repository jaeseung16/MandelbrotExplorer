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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        mandelbrotUIView.selectRect = toViewRect(displayRect: CGRect(x: 70, y: 176, width: 32, height: 32))
        mandelbrotUIView.mandelbrotRect = defaultMandelbrotRect
        mandelbrotUIView.rectScale = 1.0
    }
    
    func initializeZoomedMandelbrotDisplay() -> Void {
        zoomedMandelbrotDisplay = MandelbrotDisplayIPad(sideLength: sideLength)
        zoomedMandelbrotDisplay?.color = SIMD4<Float>(x: 0.0, y: 1.0, z: 0.0, w: 1.0)
        zoomedMandelbrotDisplay?.id = MandelbrotID.second
        
        defaultMandelbrotDisplay?.child = zoomedMandelbrotDisplay
        defaultMandelbrotDisplay?.updateChild(rect: toDisplayRect(viewRect: mandelbrotUIView.selectRect))
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
    
    func toViewRect(displayRect: CGRect) -> CGRect {
        let displaySideLength = defaultMandelbrotDisplay?.sideLength
        let viewSideLength = mandelbrotUIView.sideLength
        
        let scale = CGFloat(viewSideLength) / CGFloat(displaySideLength!)
        
        print("displaySideLength = \(displaySideLength)")
        print("viewSideLength = \(viewSideLength)")
        print("displayRect = \(displayRect)")
        print("viewRect = \(CGRect(x: scale * displayRect.origin.x, y: scale * displayRect.origin.y, width: scale * displayRect.width, height: scale * displayRect.height))")
        
        return CGRect(x: scale * displayRect.origin.x, y: scale * displayRect.origin.y, width: scale * displayRect.width, height: scale * displayRect.height)
    }
    
    func toDisplayRect(viewRect: CGRect) -> CGRect {
        let displaySideLength = defaultMandelbrotDisplay?.sideLength
        let viewSideLength = mandelbrotUIView.sideLength
        
        let scale = CGFloat(displaySideLength!) / CGFloat(viewSideLength)
        
        print("displaySideLength = \(displaySideLength)")
        print("viewSideLength = \(viewSideLength)")
        print("viewRect = \(viewRect)")
        print("displayRect = \(CGRect(x: scale * viewRect.origin.x, y: scale * viewRect.origin.y, width: scale * viewRect.width, height: scale * viewRect.height))")
        
        return CGRect(x: scale * viewRect.origin.x, y: scale * viewRect.origin.y, width: scale * viewRect.width, height: scale * viewRect.height)
    }
    
    @IBAction func refreshColor(_ sender: UIButton) {
        defaultMandelbrotDisplay?.color = SIMD4<Float>(x: redSlider.value, y: greenSlider.value, z: blueSlider.value, w: 1.0)
        defaultMandelbrotDisplay?.colorMap = nil
        defaultMandelbrotDisplay?.generateMandelbrotSet()
        mandelbrotUIView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
    }
    
    @IBAction func reset(_ sender: UIBarButtonItem) {
        mandelbrotUIView.selectRect = toViewRect(displayRect: CGRect(x: 70, y: 176, width: 32, height: 32))
        
        defaultMandelbrotDisplay?.updateChild(rect: toDisplayRect(viewRect: mandelbrotUIView.selectRect))
        
        update(mandelbrotUIView: zoomedMandelbrotUIView, with: zoomedMandelbrotDisplay!)
    }
    
    @IBAction func refreshColorWithParula256(_ sender: UIButton) {
        defaultMandelbrotDisplay?.colorMap = Parula256.colorsInSIMD4
        defaultMandelbrotDisplay?.color = nil
        defaultMandelbrotDisplay?.generateMandelbrotSet()
        mandelbrotUIView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        //self.navigationController?.dismiss(animated: true)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension MandelbrotExplorerDetailViewController: MandelbrotViewDelegate {
    func update(rect: CGRect, in id: MandelbrotID) {
        if (id == MandelbrotID.first) {
            defaultMandelbrotDisplay?.updateChild(rect: toDisplayRect(viewRect: rect))
            update(mandelbrotUIView: zoomedMandelbrotUIView, with: zoomedMandelbrotDisplay!)
        }
    }
}

