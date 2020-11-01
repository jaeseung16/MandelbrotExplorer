//
//  ColorMapFromSingleColor.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 11/1/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import CoreGraphics

struct ColorMapFromSingleColor: ColorMap {
    let length: Int
    let color: SIMD4<Float>
    var colorMapInSIMD4: [SIMD4<Float>]
    
    init(_ color: MandelbrotExplorerColors, length: Int) {
        self.color = color.toSIMD4()
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
        
        let scale = Float(index) / Float(length - 1)
        
        let red = scale * color.x
        let green = scale * color.y
        let blue = scale * color.z
 
        return SIMD4<Float>(x: red, y: green, z: blue, w: 1.0)
    }
}
