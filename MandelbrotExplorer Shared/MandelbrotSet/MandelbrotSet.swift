//
//  MandelbrotSet.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import CoreGraphics
import ComplexModule

protocol MandelbrotSet {
    var zs: [Complex<Double>] { get set }
    var values: [Int] { get set }
    var maxIter: Int { get set }
    var cgImage: CGImage {get set}
    
    func calculate(completionHandler: ((CGImage) -> Void)?) -> Void
}
