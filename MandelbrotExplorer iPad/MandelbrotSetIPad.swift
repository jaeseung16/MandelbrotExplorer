//
//  MandelbrotSetIPad.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/5/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import CoreGraphics

protocol MandelbrotSetIPad {
    var zs: [MyComplex] { get set }
    var values: [Int] { get set }
    var maxIter: Int { get set }
    var cgImage: CGImage {get set}
    
    func calculate() -> Void
}
