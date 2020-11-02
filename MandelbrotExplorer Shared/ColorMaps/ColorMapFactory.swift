//
//  ColorMapFactory.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 11/1/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

class ColorMapFactory {
    static func getColorMap(_ name: MandelbrotExplorerColorMap, length: Int) -> ColorMap {
        var colorMap: ColorMap
        
        switch (name) {
        case .parula256:
            colorMap = Parula256()
        case .jet:
            colorMap = Jet(length)
        case .hsv:
            colorMap = HSV(length)
        case .hot:
            colorMap = Hot(length)
        case .cool:
            colorMap = Cool(length)
        case .spring:
            colorMap = Spring(length)
        case .summer:
            colorMap = Summer(length)
        case .autumn:
            colorMap = Autumn(length)
        case .winter:
            colorMap = Winter(length)
        case .blue:
            colorMap = ColorMapFromSingleColor(.blue, length: length)
        case .brown:
            colorMap = ColorMapFromSingleColor(.brown, length: length)
        case .cyan:
            colorMap = ColorMapFromSingleColor(.cyan, length: length)
        case .green:
            colorMap = ColorMapFromSingleColor(.green, length: length)
        case .magenta:
            colorMap = ColorMapFromSingleColor(.magenta, length: length)
        case .orange:
            colorMap = ColorMapFromSingleColor(.orange, length: length)
        case .purple:
            colorMap = ColorMapFromSingleColor(.purple, length: length)
        case .red:
            colorMap = ColorMapFromSingleColor(.red, length: length)
        case .white:
            colorMap = ColorMapFromSingleColor(.white, length: length)
        case .yellow:
            colorMap = ColorMapFromSingleColor(.yellow, length: length)
        }
        
        return colorMap
    }
}

