//
//  Complex.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

struct MyComplex: Equatable, CustomStringConvertible {
    var real: Double
    var imaginary: Double
    
    init() {
        self.init(0, 0)
    }
    
    init(_ real: Double,_ imaginary: Double) {
        self.real = real
        self.imaginary = imaginary
    }
    
    var description: String {
        get {
            let realString = String(format: "%.4f", real)
            let imaginaryString = String(format: "%.4f", fabs(imaginary))
            var result = ""
            switch (real, imaginary) {
            case _ where imaginary == 0:
                result = "\(realString)"
            case _ where real == 0:
                result = "\(imaginaryString)𝒊"
            case _ where imaginary < 0:
                result = "\(realString) - \(imaginaryString)𝒊"
            default:
                result = "\(realString) + \(imaginaryString)𝒊"
            }
            return result
        }
    }
    
    static func ==(lhs: MyComplex, rhs: MyComplex) -> Bool {
        return lhs.real == rhs.real && lhs.imaginary == rhs.imaginary
    }
    
    static func +(lhs: MyComplex, rhs: MyComplex) -> MyComplex {
        return MyComplex(lhs.real + rhs.real, lhs.imaginary + rhs.imaginary)
    }
    
    static func -(lhs: MyComplex, rhs: MyComplex) -> MyComplex {
        return MyComplex(lhs.real - rhs.real, lhs.imaginary - rhs.imaginary)
    }
    
    static prefix func -(c1: MyComplex) -> MyComplex {
        return MyComplex( -c1.real, -c1.imaginary)
    }
    
    static func *(lhs: MyComplex, rhs: MyComplex) -> MyComplex {
        return MyComplex(lhs.real * rhs.real - lhs.imaginary * rhs.imaginary, lhs.real * rhs.imaginary + rhs.real * lhs.imaginary)
    }
    
    static func /(lhs: MyComplex, rhs: MyComplex) -> MyComplex {
        let denom = (rhs.real * rhs.real + rhs.imaginary * rhs.imaginary)
        return MyComplex((lhs.real * rhs.real + lhs.imaginary * rhs.imaginary)/denom, (lhs.imaginary * rhs.real - lhs.real * rhs.imaginary)/denom)
    }
    
    static func abs(lhs: MyComplex) -> Double {
        return sqrt(lhs.real*lhs.real + lhs.imaginary*lhs.imaginary)
    }
    
    static func modulus(lhs: MyComplex) -> Double {
        return abs(lhs: lhs)
    }
    
    static func +(lhs: Double, rhs: MyComplex) -> MyComplex { // Real plus imaginary
        return MyComplex(lhs + rhs.real, rhs.imaginary)
    }
    
    static func -(lhs: Double, rhs: MyComplex) -> MyComplex { // Real minus imaginary
        return MyComplex(lhs - rhs.real, -rhs.imaginary)
    }
    
    static func *(lhs: Double, rhs: MyComplex) -> MyComplex { // Real times imaginary
        return MyComplex(lhs * rhs.real, lhs * rhs.imaginary)
    }
}

