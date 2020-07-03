//
//  MandelbrotSet.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

protocol MandelbrotSet {
    var zs: [Complex] { get set }
    var values: [Int] { get set }
    var maxIter: Int { get set }
    var cgImage: CGImage {get set}
    
    func calculate() -> Void
}
