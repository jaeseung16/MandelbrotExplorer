//
//  MandelbrotDisplayDelegate.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/15/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation
import CoreGraphics

protocol MandelbrotViewDelegate {
    func update(rect: CGRect, in id: MandelbrotID) -> Void
}

