//
//  MandelbrotShareUIView.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 11/11/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import UIKit

class MandelbrotShareUIView: UIView {
    @IBOutlet weak var mandelbrotIUIView: MandelbrotUIView!
    
    @IBOutlet weak var realMinTextField: UITextField!
    @IBOutlet weak var realMaxTextField: UITextField!
    @IBOutlet weak var imaginaryMaxTextField: UITextField!
    @IBOutlet weak var imaginaryMinTextField: UITextField!
    
    @IBOutlet weak var maxIterLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!

}
