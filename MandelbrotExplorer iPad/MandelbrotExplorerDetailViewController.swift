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
    
    @IBOutlet weak var colorMapPickerView: UIPickerView!
    
    var defaultMandelbrotDisplay: MandelbrotDisplayIPad?
    var zoomedMandelbrotDisplay: MandelbrotDisplayIPad?
    
    let sideLength = 383
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let defaultMandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    var zoomedMandelbrotRect: ComplexRect?
    
    var mandelbrotImageGenerator: MandelbrotImageGenerator?
    var colorMap = MandelbrotExplorerColorMap.green
    
    var dataController: DataController!
    var defaultMandelbrotEntity: MandelbrotEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        colorMapPickerView.delegate = self
        
        var row = 0
        for colorMap in MandelbrotExplorerColorMap.allCases {
            if (colorMap == self.colorMap) {
                break
            }
            row += 1
        }
        
        colorMapPickerView.selectRow(row, inComponent: 0, animated: false)
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
        defaultMandelbrotDisplay?.id = MandelbrotID.first
        
        let minReal = defaultMandelbrotEntity.minReal
        let maxReal = defaultMandelbrotEntity.maxReal
        let minImaginary = defaultMandelbrotEntity.minImaginary
        let maxImaginary = defaultMandelbrotEntity.maxImaginary
        
        if defaultMandelbrotEntity.colorMap == 0 {
            defaultMandelbrotDisplay?.color = SIMD4<Float>(x: defaultMandelbrotEntity.red, y: defaultMandelbrotEntity.green, z: defaultMandelbrotEntity.blue, w: 1.0)
        } else {
            defaultMandelbrotDisplay?.colorMap = nil
        }
        
        let mandelbrotRect = ComplexRect(Complex<Double>(minReal, minImaginary), Complex<Double>(maxReal, maxImaginary))
        defaultMandelbrotDisplay?.mandelbrotRect = mandelbrotRect
        
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
        zoomedMandelbrotDisplay?.colorMap = ColorMapFactory.getColorMap(colorMap, length: 256).colorMapInSIMD4
        zoomedMandelbrotDisplay?.color = nil
        zoomedMandelbrotDisplay?.generateMandelbrotSet()
        zoomedMandelbrotUIView.mandelbrotImage = zoomedMandelbrotDisplay?.mandelbrotImage
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let mandelbrotEntity = MandelbrotEntity(context: dataController.viewContext)
        
        let mandelbrotRect = zoomedMandelbrotDisplay!.mandelbrotRect
        
        mandelbrotEntity.minReal = mandelbrotRect.minReal
        mandelbrotEntity.maxReal = mandelbrotRect.maxReal
        mandelbrotEntity.minImaginary = mandelbrotRect.minImaginary
        mandelbrotEntity.maxImaginary = mandelbrotRect.maxImaginary
        
        if let color = zoomedMandelbrotDisplay!.color {
            mandelbrotEntity.red = color.x
            mandelbrotEntity.green = color.y
            mandelbrotEntity.blue = color.z
        }
        
        mandelbrotEntity.image = zoomedMandelbrotUIView.mandelbrotImage?.pngData()
        
        do {
            try dataController.viewContext.save()
            NSLog("Saved in SearchByNameViewController.saveCompound(:)")
        } catch {
            NSLog("Error while saving in SearchByNameViewController.saveCompound(:)")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reset(_ sender: UIBarButtonItem) {
        mandelbrotUIView.selectRect = toViewRect(displayRect: CGRect(x: 70, y: 176, width: 32, height: 32))
        
        defaultMandelbrotDisplay?.updateChild(rect: toDisplayRect(viewRect: mandelbrotUIView.selectRect))
        
        update(mandelbrotUIView: zoomedMandelbrotUIView, with: zoomedMandelbrotDisplay!)
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

extension MandelbrotExplorerDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MandelbrotExplorerColorMap.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let colorMap = UILabel()
        colorMap.textAlignment = .center
        colorMap.text = MandelbrotExplorerColorMap.allCases[row].rawValue
        return colorMap
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        colorMap = MandelbrotExplorerColorMap.allCases[row]
    }
}
