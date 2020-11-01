//
//  ColorMap.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 10/31/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

protocol ColorMap {
    var colorMapInSIMD4: [SIMD4<Float>] { get }
}
