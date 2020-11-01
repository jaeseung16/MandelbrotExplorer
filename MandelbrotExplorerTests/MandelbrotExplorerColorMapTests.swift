//
//  MandelbrotExplorerColorMapTests.swift
//  MandelbrotExplorerTests
//
//  Created by Jae Seung Lee on 10/31/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import XCTest
@testable import MandelbrotExplorer

class MandelbrotExplorerColorMapTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJet256() throws {
        let jet256InSIMD4 = Jet(256).colorMapInSIMD4
        let expected = Jet.colorMap256
        
        for k in 0..<expected.count {
            XCTAssertEqual(jet256InSIMD4[k].x, expected[k].x, accuracy: Float.ulpOfOne)
            XCTAssertEqual(jet256InSIMD4[k].y, expected[k].y, accuracy: Float.ulpOfOne)
            XCTAssertEqual(jet256InSIMD4[k].z, expected[k].z, accuracy: Float.ulpOfOne)
        }
    }

    func testHSV256() throws {
        let hsv256InSIMD4 = HSV(256).colorMapInSIMD4
        let expected = HSV.colorMap256
        
        
        
        for k in 0..<expected.count {
            print("k = \(k): \(hsv256InSIMD4[k]) \(expected[k])")
            XCTAssertEqual(hsv256InSIMD4[k].x, expected[k].x, accuracy: Float.ulpOfOne)
            XCTAssertEqual(hsv256InSIMD4[k].y, expected[k].y, accuracy: Float.ulpOfOne)
            XCTAssertEqual(hsv256InSIMD4[k].z, expected[k].z, accuracy: Float.ulpOfOne)
        }
    }
    
    func testHot256() throws {
        let hot256InSIMD4 = Hot(256).colorMapInSIMD4
        let expected = Hot.colorMap256
        
        for k in 0..<expected.count {
            XCTAssertEqual(hot256InSIMD4[k].x, expected[k].x, accuracy: Float.ulpOfOne)
            XCTAssertEqual(hot256InSIMD4[k].y, expected[k].y, accuracy: Float.ulpOfOne)
            XCTAssertEqual(hot256InSIMD4[k].z, expected[k].z, accuracy: Float.ulpOfOne)
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
