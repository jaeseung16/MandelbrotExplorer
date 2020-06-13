//
//  MandelbrotSet.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

class MandelbrotSet {
    var zs: [Complex];
    var values: [Int];
    
    var maxIter = 50;
    
    init(inZs: [Complex], inMaxIter: Int) {
        zs = inZs
        maxIter = inMaxIter
            
        values = [Int](repeating: 0, count: zs.count)

        calculate()
    }
    
    func calculate() -> Void{
        for k in (0..<zs.count) {
            values[k] = mandelbrotFormula(z0: zs[k])
        }
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
