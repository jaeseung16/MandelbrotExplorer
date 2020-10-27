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
}
