//
//  Summer.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 10/30/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

struct Summer: ColorMap {
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
        guard (length > 0 && index >= 0 && index < length) else {
            return nil
        }
        
        let red = Float(index) / Float(length - 1)
        let green = 0.5 * ( 1.0 + Float(index) / Float(length - 1) )
        let blue = Float(0.4)
        
        return SIMD4<Float>(x: red, y: green, z: blue, w: 1.0)
    }
}
