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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeDefaultMandelbrotDisplay()
        
        initializeDefaultMandelbrotView()
        
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
            
            
            if mandelbrotEntity!.colorMap == 0 {
                mandelbrotDisplay?.color = SIMD4<Float>(x: mandelbrotEntity!.red, y: mandelbrotEntity!.green, z: mandelbrotEntity!.blue, w: 1.0)
            } else {
                mandelbrotDisplay?.colorMap = nil
            }
            
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
