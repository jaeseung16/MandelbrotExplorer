//
//  ComplexRect.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

struct ComplexRect: Equatable, CustomStringConvertible {
    var topLeft: Complex
    var bottomRight: Complex
    private(set) var bottomLeft: Complex
    private(set) var topRight: Complex
    
    init(_ c1: Complex, _ c2: Complex) {
        let tlr = min(c1.real, c2.real)
        let tli = max(c1.imaginary, c2.imaginary)
        let brr = max(c1.real, c2.real)
        let bri = min(c1.imaginary, c2.imaginary)
        topLeft = Complex(tlr, tli)
        bottomRight = Complex(brr, bri)
        bottomLeft = Complex(tlr, bri)
        topRight = Complex(brr, tli)
    }
    
    var description: String {
        return "tl:\(topLeft), br:\(bottomRight), bl:\(bottomLeft), tr:\(topRight)"
    }
    
    static func ==(lhs: ComplexRect, rhs: ComplexRect) -> Bool {
        return (lhs.topLeft == rhs.topLeft) && (lhs.bottomRight == rhs.bottomRight)
    }
}


