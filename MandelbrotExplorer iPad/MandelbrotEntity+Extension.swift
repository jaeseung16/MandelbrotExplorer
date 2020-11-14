//
//  MandelbrotEntity+Extension.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/27/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import CoreData

extension MandelbrotEntity {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        created = Date()
    }
    
    public override var description: String {
        let minReal = String(format: "%.2f", self.minReal)
        let maxReal = String(format: "%.2f", self.maxReal)
        let minImaginary = String(format: "%.2f", self.minImaginary)
        let maxImaginary = String(format: "%.2f", self.maxImaginary)
        
        return ("Real: \t\t(\(minReal), \(maxReal))\nImaginary: \t(\(minImaginary), \(maxImaginary))")
    }
    
    public var detailedDescription: String {
        let minReal = String(format: "%.6f", self.minReal)
        let maxReal = String(format: "%.6f", self.maxReal)
        let minImaginary = String(format: "%.6f", self.minImaginary)
        let maxImaginary = String(format: "%.6f", self.maxImaginary)
        
        return "Real: (\(minReal), \(maxReal))\nImaginary: (\(minImaginary), \(maxImaginary))\nMax Iter: \(maxIter)"
    }
}
