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
    
    @IBOutlet weak var colorMapPickerView: UIPickerView!
    @IBOutlet weak var realMinTextField: UITextField!
    @IBOutlet weak var realMaxTextField: UITextField!
    @IBOutlet weak var imaginaryMinTextField: UITextField!
    @IBOutlet weak var imaginaryMaxTextField: UITextField!
    
    @IBOutlet weak var scaleLabel: UILabel!
    
    var maxIter = MaxIter.twoHundred.rawValue
    
    var defaultMandelbrotDisplay: MandelbrotDisplayIPad?
    var zoomedMandelbrotDisplay: MandelbrotDisplayIPad?
    
    let sideLength = MandelbrotConstant.sideLength
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let defaultMandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    var zoomedMandelbrotRect: ComplexRect?
    
    var mandelbrotImageGenerator: MandelbrotImageGenerator?
    var colorMap = MandelbrotExplorerColorMap.green
    
    var dataController: DataController!
    var defaultMandelbrotEntity: MandelbrotEntity!
    
    let defaultSideLength: CGFloat = 32
    var _rectSideLength: CGFloat = 32
    var rectSideLength: CGFloat {
        get {
            return _rectSideLength
        }
        set {
            _rectSideLength = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        maxIter = Int(defaultMandelbrotEntity.maxIter)
        setupColorMapPickerView()
        
        rectSideLength = defaultSideLength
        scaleLabel.text = String(format: "%.3f", Float(sideLength) / Float(rectSideLength))
    }
    
    private func setupColorMapPickerView() {
        colorMapPickerView.delegate = self
        colorMapPickerView.dataSource = self
        
        var row = 0
        for colorMap in MandelbrotExplorerColorMap.allCases {
            if (colorMap == self.colorMap) {
                break
            }
            row += 1
        }
        
        colorMapPickerView.selectRow(row, inComponent: 0, animated: false)
        
        row = 0
        while (row < MaxIter.allCases.count) {
            if MaxIter.allCases[row].rawValue == maxIter {
                break
            }
            row += 1
        }
        
        colorMapPickerView.selectRow(row, inComponent: 1, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeDefaultMandelbrotDisplay()
        
        initializeDefaultMandelbrotView()
        
        initializeZoomedMandelbrotDisplay()
        
        initializeZoomedMandelbrotView()
        
        updateTextFields()
    }

    func initializeDefaultMandelbrotDisplay() {
        defaultMandelbrotDisplay = MandelbrotDisplayIPad(sideLength: sideLength, maxIter: maxIter)
        defaultMandelbrotDisplay?.id = MandelbrotID.first
        
        let minReal = defaultMandelbrotEntity.minReal
        let maxReal = defaultMandelbrotEntity.maxReal
        let minImaginary = defaultMandelbrotEntity.minImaginary
        let maxImaginary = defaultMandelbrotEntity.maxImaginary
        
        let defaultMandelbrotExplorerColorMap = MandelbrotExplorerColorMap(rawValue: defaultMandelbrotEntity.colorMap!)
        defaultMandelbrotDisplay?.colorMap = ColorMapFactory.getColorMap(defaultMandelbrotExplorerColorMap!,
                                                                         length: MaxIter(rawValue: maxIter)!.normalize())
            .colorMapInSIMD4
        
        let mandelbrotRect = ComplexRect(Complex<Double>(minReal, minImaginary), Complex<Double>(maxReal, maxImaginary))
        defaultMandelbrotDisplay?.mandelbrotRect = mandelbrotRect
        
        defaultMandelbrotDisplay?.generateMandelbrotSet()
    }
    
    func initializeDefaultMandelbrotView() {
        mandelbrotUIView.delegate = self
        mandelbrotUIView.id = MandelbrotID.first
        mandelbrotUIView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
        mandelbrotUIView.selectRect = toViewRect(displayRect: CGRect(x: 70, y: 176, width: rectSideLength, height: rectSideLength))
        mandelbrotUIView.mandelbrotRect = defaultMandelbrotRect
        mandelbrotUIView.rectScale = 1.0
    }
    
    func initializeZoomedMandelbrotDisplay() -> Void {
        zoomedMandelbrotDisplay = MandelbrotDisplayIPad(sideLength: sideLength, maxIter: maxIter)
        zoomedMandelbrotDisplay?.colorMap = ColorMapFactory.getColorMap(colorMap,
                                                                        length: MaxIter(rawValue: maxIter)!.normalize())
            .colorMapInSIMD4
        zoomedMandelbrotDisplay?.id = MandelbrotID.second
        
        defaultMandelbrotDisplay?.child = zoomedMandelbrotDisplay
        defaultMandelbrotDisplay?.updateChild(rect: toDisplayRect(viewRect: mandelbrotUIView.selectRect))
    }
    
    func initializeZoomedMandelbrotView() -> Void {
        zoomedMandelbrotUIView.delegate = self
        zoomedMandelbrotUIView.id = MandelbrotID.second
        
        update(mandelbrotUIView: zoomedMandelbrotUIView, with: zoomedMandelbrotDisplay!)
    }
    
    private func update(mandelbrotUIView: MandelbrotUIView, with mandelbrotDisplayIPad: MandelbrotDisplayIPad) -> Void {
        mandelbrotUIView.mandelbrotImage = mandelbrotDisplayIPad.mandelbrotImage
        mandelbrotUIView.mandelbrotRect = mandelbrotDisplayIPad.mandelbrotRect
        mandelbrotUIView.rectScale = (defaultMandelbrotRect.maxReal - defaultMandelbrotRect.minReal) / (mandelbrotUIView.mandelbrotRect.maxReal - mandelbrotUIView.mandelbrotRect.minReal)
        
        updateTextFields()
    }
    
    func toViewRect(displayRect: CGRect) -> CGRect {
        let displaySideLength = defaultMandelbrotDisplay?.sideLength
        let viewSideLength = mandelbrotUIView.sideLength
        let scale = CGFloat(viewSideLength) / CGFloat(displaySideLength!)
        return CGRect(x: scale * displayRect.origin.x,
                      y: scale * displayRect.origin.y,
                      width: scale * displayRect.width,
                      height: scale * displayRect.height)
    }
    
    func toDisplayRect(viewRect: CGRect) -> CGRect {
        let displaySideLength = defaultMandelbrotDisplay?.sideLength
        let viewSideLength = mandelbrotUIView.sideLength
        let scale = CGFloat(displaySideLength!) / CGFloat(viewSideLength)
        return CGRect(x: scale * viewRect.origin.x,
                      y: scale * viewRect.origin.y,
                      width: scale * viewRect.width,
                      height: scale * viewRect.height)
    }
    
    func updateTextFields() {
        if let mandelbrotDisplay = zoomedMandelbrotDisplay {
            let format = "%.6f"
            realMinTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.minReal)
            realMaxTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.maxReal)
            imaginaryMinTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.minImaginary)
            imaginaryMaxTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.maxImaginary)
        }
    }
    
    private func refresh() {
        zoomedMandelbrotDisplay?.colorMap = ColorMapFactory.getColorMap(colorMap,
                                                                        length: MaxIter(rawValue: maxIter)!.normalize())
            .colorMapInSIMD4
        zoomedMandelbrotDisplay?.maxIter = maxIter
        zoomedMandelbrotDisplay?.generateMandelbrotSet()
        zoomedMandelbrotUIView.mandelbrotImage = zoomedMandelbrotDisplay?.mandelbrotImage
    }
    
    @IBAction func refresh(_ sender: UIButton) {
        refresh()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        refresh()
        
        let mandelbrotEntity = MandelbrotEntity(context: dataController.viewContext)
        
        let mandelbrotRect = zoomedMandelbrotDisplay!.mandelbrotRect
        
        mandelbrotEntity.minReal = mandelbrotRect.minReal
        mandelbrotEntity.maxReal = mandelbrotRect.maxReal
        mandelbrotEntity.minImaginary = mandelbrotRect.minImaginary
        mandelbrotEntity.maxImaginary = mandelbrotRect.maxImaginary
        mandelbrotEntity.colorMap = colorMap.rawValue
        mandelbrotEntity.maxIter = Int32(zoomedMandelbrotDisplay!.maxIter)
        
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
        rectSideLength = defaultSideLength
        
        scaleLabel.text = String(format: "%.3f", Float(sideLength) / Float(rectSideLength))
        
        mandelbrotUIView.selectRect = toViewRect(displayRect: CGRect(x: 70, y: 176, width: rectSideLength, height: rectSideLength))
        
        defaultMandelbrotDisplay?.updateChild(rect: toDisplayRect(viewRect: mandelbrotUIView.selectRect))
        
        update(mandelbrotUIView: zoomedMandelbrotUIView, with: zoomedMandelbrotDisplay!)
    }
    
}

extension MandelbrotExplorerDetailViewController: MandelbrotViewDelegate {
    func update(rect: CGRect, in id: MandelbrotID) {
        if (id == MandelbrotID.first) {
            let displayRect = toDisplayRect(viewRect: rect)
            defaultMandelbrotDisplay?.updateChild(rect: displayRect)
            
            rectSideLength = displayRect.width
            scaleLabel.text = String(format: "%.3f", Float(sideLength) / Float(rectSideLength))
            
            update(mandelbrotUIView: zoomedMandelbrotUIView, with: zoomedMandelbrotDisplay!)
        }
    }
}

extension MandelbrotExplorerDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows: Int
        
        switch component {
        case 0:
            numberOfRows = MandelbrotExplorerColorMap.allCases.count
        case 1:
            numberOfRows = MaxIter.allCases.count
        default:
            numberOfRows = 0
        }
        return numberOfRows
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if view == nil {
            switch component {
            case 0:
                let colorMap = UILabel()
                colorMap.textAlignment = .center
                colorMap.text = MandelbrotExplorerColorMap.allCases[row].rawValue
                return colorMap
            case 1:
                let maxIter = UILabel()
                maxIter.textAlignment = .center
                maxIter.text = String(MaxIter.allCases[row].rawValue)
                return maxIter
            default:
                return UIView()
            }
        } else {
            return view!
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            colorMap = MandelbrotExplorerColorMap.allCases[row]
        case 1:
            maxIter = MaxIter.allCases[row].rawValue
        default:
            colorMap = MandelbrotExplorerColorMap.allCases[0]
            maxIter = MaxIter.twoHundred.rawValue
        }
    }
}
