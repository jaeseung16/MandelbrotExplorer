//
//  MaxIter.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 11/11/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Foundation

enum MaxIter: Int, CaseIterable {
    static let maxColorStep = 8192
    
    case fifty = 50
    case oneHundred = 100
    case twoHundred = 200
    case threeHundred = 300
    case founHundred = 400
    case fiveHundred = 500
    case sixHundred = 600
    case sevenHundred = 700
    case eightHundred = 800
    case nineHundred = 900
    case oneThousand = 1000
    case twoThousand = 2000
    case threeThousand = 3000
    case fourThousand = 4000
    case fiveThousand = 5000
    case sixThousand = 6000
    case sevenThousand = 7000
    case eightThousand = 8000
    
    case nineThousand = 9000
    case tenThousand = 10000
    case oneHundredThousand = 100000
    case oneMillion = 1000000
    
    func normalize() -> Int {
        return self.rawValue > MaxIter.maxColorStep ? MaxIter.maxColorStep : self.rawValue
    }
}
