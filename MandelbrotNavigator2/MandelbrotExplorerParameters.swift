//
//  MandelbrotExplorerParameters.swift
//  MandelbrotNavigator2
//
//  Created by Jae Seung Lee on 9/24/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import Foundation

struct MandelbrotExplorerParameters {
    static let calculationSize: Int = 512
    
    let maxIter: MaxIter
    let colorMap: MandelbrotExplorerColorMap
    let generatingDevice: MandelbrotSetGeneratingDevice
    
    
}
