//
//  ColorConverter.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 10/22/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import CoreGraphics

class ColorConverter {
    static func toSIMD4(inColor: CGColor) -> SIMD4<Float> {
        return SIMD4<Float>(x: Float(inColor.components![0]), y: Float(inColor.components![1]), z: Float(inColor.components![2]), w: Float(inColor.alpha))
    }

    static func toCGColor(inSIMD4: SIMD4<Float>) -> CGColor {
        return CGColor(red: CGFloat(inSIMD4.x), green: CGFloat(inSIMD4.y), blue: CGFloat(inSIMD4.z), alpha: CGFloat(inSIMD4.w))
    }
}
