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
        let format = "%.2f"
        let minReal = String(format: format, self.minReal)
        let maxReal = String(format: format, self.maxReal)
        let minImaginary = String(format: format, self.minImaginary)
        let maxImaginary = String(format: format, self.maxImaginary)
        
        return ("Real: \t\t(\(minReal), \(maxReal))\nImaginary: \t(\(minImaginary), \(maxImaginary))")
    }
    
    public var detailedDescription: String {
        let format = "%.6f"
        let minReal = String(format: format, self.minReal)
        let maxReal = String(format: format, self.maxReal)
        let minImaginary = String(format: format, self.minImaginary)
        let maxImaginary = String(format: format, self.maxImaginary)
        
        return "Real: (\(minReal), \(maxReal))\nImaginary: (\(minImaginary), \(maxImaginary))\nMax Iter: \(maxIter)"
    }
}
