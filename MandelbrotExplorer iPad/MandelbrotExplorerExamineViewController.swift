//
//  MandelbrotExplorerExamineViewController.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/26/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import UIKit
import ComplexModule

class MandelbrotExplorerExamineViewController: UIViewController {

    @IBOutlet weak var mandelbrotIUIView: MandelbrotUIView!
    @IBOutlet weak var exploreBarButton: UIBarButtonItem!
    
    @IBOutlet weak var realMinTextField: UITextField!
    @IBOutlet weak var realMaxTextField: UITextField!
    @IBOutlet weak var imaginaryMaxTextField: UITextField!
    @IBOutlet weak var imaginaryMinTextField: UITextField!
    
    
    var mandelbrotDisplay: MandelbrotDisplayIPad?
    
    let sideLength = 383
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let defaultMandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    
    var mandelbrotImageGenerator: MandelbrotImageGenerator?
    
    var dataController: DataController?
    var mandelbrotEntity: MandelbrotEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        exploreBarButton.isEnabled = mandelbrotEntity != nil
        
        realMinTextField.transform = CGAffineTransform(rotationAngle: CGFloat(-1.0 * Double.pi / 2.0))
            .concatenating(CGAffineTransform(translationX: CGFloat(30.0), y: CGFloat(0.0)))
        realMaxTextField.transform = CGAffineTransform(rotationAngle: CGFloat(-1.0 * Double.pi / 2.0))
            .concatenating(CGAffineTransform(translationX: CGFloat(-30.0), y: CGFloat(0.0)))
            
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeDefaultMandelbrotDisplay()
        
        initializeDefaultMandelbrotView()
        
        initializeTextFields()
    }
    
    func initializeDefaultMandelbrotDisplay() {
        mandelbrotDisplay = MandelbrotDisplayIPad(sideLength: sideLength)
        mandelbrotDisplay?.id = MandelbrotID.first
        
        if (mandelbrotEntity == nil) {
            mandelbrotDisplay?.color = SIMD4<Float>(x: 0.0, y: 1.0, z: 1.0, w: 1.0)
            mandelbrotDisplay?.mandelbrotRect = defaultMandelbrotRect
        } else {
            let minReal = mandelbrotEntity!.minReal
            let maxReal = mandelbrotEntity!.maxReal
            let minImaginary = mandelbrotEntity!.minImaginary
            let maxImaginary = mandelbrotEntity!.maxImaginary
            
            let mandelbrotExplorerColorMap = MandelbrotExplorerColorMap.init(rawValue: mandelbrotEntity!.colorMap!)
            mandelbrotDisplay?.colorMap = ColorMapFactory.getColorMap(mandelbrotExplorerColorMap!, length: 256).colorMapInSIMD4
            
            let mandelbrotRect = ComplexRect(Complex<Double>(minReal, minImaginary), Complex<Double>(maxReal, maxImaginary))
            
            mandelbrotDisplay?.mandelbrotRect = mandelbrotRect
        }
        
        mandelbrotDisplay?.generateMandelbrotSet()
    }
    
    func initializeDefaultMandelbrotView() {
        mandelbrotIUIView.id = MandelbrotID.first
        mandelbrotIUIView.mandelbrotImage = mandelbrotDisplay?.mandelbrotImage
        mandelbrotIUIView.mandelbrotRect = defaultMandelbrotRect
        mandelbrotIUIView.rectScale = 1.0
    }

    func initializeTextFields() {
        if let mandelbrotDisplay = mandelbrotDisplay {
            realMinTextField.text = String(format: "%.6f", mandelbrotDisplay.mandelbrotRect.minReal)
            realMaxTextField.text = String(format: "%.6f", mandelbrotDisplay.mandelbrotRect.maxReal)
            imaginaryMinTextField.text = String(format: "%.6f", mandelbrotDisplay.mandelbrotRect.minImaginary)
            imaginaryMaxTextField.text = String(format: "%.6f", mandelbrotDisplay.mandelbrotRect.maxImaginary)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let mandelbrotExplorerDetailViewController = segue.destination as? MandelbrotExplorerDetailViewController {
            mandelbrotExplorerDetailViewController.dataController = dataController
            mandelbrotExplorerDetailViewController.defaultMandelbrotEntity = mandelbrotEntity
        }
    }
    

}
