//
//  ComplexRect.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import ComplexModule

struct ComplexRect: Equatable, CustomStringConvertible {
    var topLeft: Complex<Double>
    var bottomRight: Complex<Double>
    private(set) var bottomLeft: Complex<Double>
    private(set) var topRight: Complex<Double>
    
    var minReal: Double
    var minImaginary: Double
    var maxReal: Double
    var maxImaginary: Double
    
    init(_ c1: Complex<Double>, _ c2: Complex<Double>) {
        minReal = min(c1.real, c2.real)
        maxImaginary = max(c1.imaginary, c2.imaginary)
        maxReal = max(c1.real, c2.real)
        minImaginary = min(c1.imaginary, c2.imaginary)
        topLeft = Complex<Double>(minReal, maxImaginary)
        bottomRight = Complex<Double>(maxReal, minImaginary)
        bottomLeft = Complex<Double>(minReal, minImaginary)
        topRight = Complex<Double>(maxReal, maxImaginary)
    }
    
    var description: String {
        return "tl:\(topLeft), br:\(bottomRight), bl:\(bottomLeft), tr:\(topRight)"
    }
    
    static func ==(lhs: ComplexRect, rhs: ComplexRect) -> Bool {
        return (lhs.topLeft == rhs.topLeft) && (lhs.bottomRight == rhs.bottomRight)
    }
}


