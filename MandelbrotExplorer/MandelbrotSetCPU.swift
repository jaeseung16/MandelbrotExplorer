//
//  MandelbrotSetCPU.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/14/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

class MandelbrotSetCPU: MandelbrotSet {
    var _zs: [Complex]
    var zs: [Complex] {
        get {
            return _zs
        }
        set {
            _zs = newValue
        }
    }
    
    var _maxIter: Int
    var maxIter: Int {
        get {
            return _maxIter
        }
        set {
            _maxIter = newValue
        }
    }
    
    var _values: [Int]
    var values: [Int] {
        get {
            return _values
        }
        set {
            _values = newValue
        }
    }
    
    init(inZs: [Complex], inMaxIter: Int) {
        _zs = inZs
        _maxIter = inMaxIter
            
        _values = [Int](repeating: 0, count: _zs.count)

        calculate()
    }
    
    func calculate() -> Void{
        values = zs.map({ (z0) -> Int in
            mandelbrotFormula(z0: z0)
        })
    }
    
    func mandelbrotFormula(z0: Complex) -> Int {
        var z = z0
        var iter = 0;
        while (iter < maxIter)
        {
            if (Complex.abs(lhs: z) > 2.0) {
                break
            }
            z = z * z + z0
            iter += 1
        }

        return (maxIter == iter) ? 0 : Int((Float(iter) / Float(maxIter) * 255.0))
    }
    
    func toData() -> Data {
        return Data()
    }
}
