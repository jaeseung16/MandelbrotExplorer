//
//  ViewController.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/4/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import UIKit

class MandelbrotExplorerDetailViewController: UIViewController {

    @IBOutlet weak var mandelbrotUIView: MandelbrotUIView!
    
    var defaultMandelbrotDisplay: MandelbrotDisplayIPad?
    
    let sideLength = 383
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let defaultMandelbrotRect = ComplexRect(Complex(-2.1, -1.5), Complex(0.9, 1.5))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        defaultMandelbrotDisplay = MandelbrotDisplayIPad(sideLength: sideLength)
        defaultMandelbrotDisplay?.id = MandelbrotID.first
        defaultMandelbrotDisplay?.mandelbrotRect = defaultMandelbrotRect
        defaultMandelbrotDisplay?.generateMandelbrotSet()
        
        //mandelbrotUIView.delegate = self
        mandelbrotUIView.id = MandelbrotID.first
        mandelbrotUIView.mandelbrotImage = defaultMandelbrotDisplay?.mandelbrotImage
        mandelbrotUIView.selectRect = CGRect(x: 70, y: 176, width: 32, height: 32)
        mandelbrotUIView.mandelbrotRect = defaultMandelbrotRect
        mandelbrotUIView.rectScale = 1.0
    }


}

