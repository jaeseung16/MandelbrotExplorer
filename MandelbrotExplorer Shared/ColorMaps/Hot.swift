//
//  Hot.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 10/30/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

struct Hot: ColorMap {
    let sections = 16
    let length: Int
    var colorMapInSIMD4: [SIMD4<Float>]
    
    init(_ length: Int) {
        self.length = length
        self.colorMapInSIMD4 = [SIMD4<Float>]()
        
        for k in 0..<length {
            colorMapInSIMD4.append(colorInSIMD4(k)!)
        }
    }
    
    func colorInSIMD4(_ index: Int) -> SIMD4<Float>? {
        guard (index >= 0 && index < length) else {
            return nil
        }
        
        let section = sections * index / length
        let sectionWidth = Float(length) / Float(sections)
        
        var color: SIMD4<Float>?
        switch (section) {
        case 0, 1, 2, 3, 4, 5:
            let red = 1.0 * Float(index + 1) / (6.0 * sectionWidth)
            color = SIMD4<Float>(x: red, y: 0.0, z: 0.0, w: 1.0)
        case 6, 7, 8, 9, 10, 11:
            let green = 1.0 * (Float(index + 1) / (6.0 * sectionWidth) - 1.0)
            color = SIMD4<Float>(x: 1.0, y: green, z: 0.0, w: 1.0)
        case 12, 13, 14, 15:
            let blue = 1.0 * (Float(index + 1) / (4.0 * sectionWidth) - 3.0)
            color = SIMD4<Float>(x: 1.0, y: 1.0, z: blue, w: 1.0)
        default:
            color = nil
        }
        
        return color
    }
    
    static let colorMap256 = [SIMD4<Float>(0.010416666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.020833333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.031250000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.041666666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.052083333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.062500000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.072916666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.083333333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.093750000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.104166666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.114583333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.125000000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.135416666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.145833333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.156250000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.166666666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.177083333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.187500000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.197916666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.208333333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.218750000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.229166666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.239583333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.250000000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.260416666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.270833333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.281250000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.291666666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.302083333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.312500000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.322916666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.333333333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.343750000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.354166666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.364583333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.375000000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.385416666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.395833333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.406250000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.416666666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.427083333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.437500000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.447916666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.458333333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.468750000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.479166666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.489583333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.500000000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.510416666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.520833333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.531250000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.541666666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.552083333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.562500000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.572916666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.583333333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.593750000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.604166666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.614583333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.625000000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.635416666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.645833333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.656250000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.666666666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.677083333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.687500000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.697916666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.708333333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.718750000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.729166666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.739583333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.750000000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.760416666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.770833333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.781250000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.791666666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.802083333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.812500000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.822916666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.833333333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.843750000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.854166666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.864583333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.875000000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.885416666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.895833333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.906250000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.916666666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.927083333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.937500000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.947916666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.958333333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.968750000000000, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.979166666666667, 0.0, 0.0, 1.0),
                              SIMD4<Float>(0.989583333333333, 0.0, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.0, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.010416666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.020833333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.031250000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.041666666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.052083333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.062500000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.072916666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.083333333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.093750000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.104166666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.114583333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.125000000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.135416666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.145833333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.156250000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.166666666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.177083333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.187500000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.197916666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.208333333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.218750000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.229166666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.239583333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.250000000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.260416666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.270833333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.281250000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.291666666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.302083333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.312500000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.322916666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.333333333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.343750000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.354166666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.364583333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.375000000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.385416666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.395833333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.406250000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.416666666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.427083333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.437500000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.447916666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.458333333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.468750000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.479166666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.489583333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.500000000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.510416666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.520833333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.531250000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.541666666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.552083333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.562500000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.572916666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.583333333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.593750000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.604166666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.614583333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.625000000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.635416666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.645833333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.656250000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.666666666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.677083333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.687500000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.697916666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.708333333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.718750000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.729166666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.739583333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.750000000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.760416666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.770833333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.781250000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.791666666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.802083333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.812500000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.822916666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.833333333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.843750000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.854166666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.864583333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.875000000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.885416666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.895833333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.906250000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.916666666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.927083333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.937500000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.947916666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.958333333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.968750000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.979166666666667, 0.0, 1.0),
                              SIMD4<Float>(1.0, 0.989583333333333, 0.0, 1.0),
                              SIMD4<Float>(1.0, 1.000000000000000, 0.0, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.015625000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.031250000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.046875000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.062500000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.078125000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.093750000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.109375000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.125000000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.140625000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.156250000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.171875000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.187500000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.203125000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.218750000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.234375000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.250000000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.265625000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.281250000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.296875000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.312500000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.328125000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.343750000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.359375000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.375000000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.390625000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.406250000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.421875000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.437500000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.453125000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.468750000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.484375000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.500000000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.515625000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.531250000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.546875000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.562500000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.578125000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.593750000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.609375000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.625000000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.640625000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.656250000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.671875000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.687500000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.703125000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.718750000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.734375000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.750000000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.765625000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.781250000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.796875000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.812500000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.828125000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.843750000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.859375000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.875000000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.890625000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.906250000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.921875000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.937500000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.953125000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.968750000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 0.984375000000000, 1.0),
                              SIMD4<Float>(1.0, 1.0, 1.000000000000000, 1.0)]
}
