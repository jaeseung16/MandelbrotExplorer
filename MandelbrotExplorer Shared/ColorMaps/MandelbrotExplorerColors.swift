//
//  MandelbrotExplorerColors.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 11/1/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

enum MandelbrotExplorerColors {
    case blue
    case brown
    case cyan
    case green
    case magenta
    case orange
    case purple
    case white
    case yellow
    
    func toSIMD4<T: BinaryFloatingPoint>() -> SIMD4<T> {
        var color: SIMD4<T>
        switch (self) {
        case .blue:
            color = SIMD4<T>(x: 0.0, y: 0.0, z: 1.0, w: 1.0)
        case .brown:
            color = SIMD4<T>(x: 0.6, y: 0.4, z: 0.2, w: 1.0)
        case .cyan:
            color = SIMD4<T>(x: 0.0, y: 1.0, z: 1.0, w: 1.0)
        case .green:
            color = SIMD4<T>(x: 0.0, y: 1.0, z: 0.0, w: 1.0)
        case .magenta:
            color = SIMD4<T>(x: 1.0, y: 0.0, z: 1.0, w: 1.0)
        case .orange:
            color = SIMD4<T>(x: 1.0, y: 0.5, z: 0.0, w: 1.0)
        case .purple:
            color = SIMD4<T>(x: 0.5, y: 0.0, z: 0.5, w: 1.0)
        case .white:
            color = SIMD4<T>(x: 1.0, y: 1.0, z: 1.0, w: 1.0)
        case .yellow:
            color = SIMD4<T>(x: 1.0, y: 1.0, z: 0.0, w: 1.0)
        }
        return color
    }
}
