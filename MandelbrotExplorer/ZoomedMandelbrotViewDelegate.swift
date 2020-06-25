//
//  ZoomedMandelbrotViewDelegate.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/24/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

protocol ZoomedMandelbrotViewDelegate {
    func updateZoomed(rect: CGRect) -> Void
}
