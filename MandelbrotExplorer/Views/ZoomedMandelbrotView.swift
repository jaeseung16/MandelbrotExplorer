//
//  MandelbrotView.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 5/25/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Cocoa
import ComplexModule

class ZoomedMandelbrotView: NSView {
    var selectRect = CGRect(x: 70, y: 175, width: 32, height: 32)
    var selectRectColor = NSColor.white
    
    var _mandelbrotRect = ComplexRect(Complex<Double>(-1.55, -0.13), Complex<Double>(-1.30, 0.12))
    
    var mandelbrotRect: ComplexRect {
        set {
            _mandelbrotRect = newValue
            print("newValue = \(newValue)")
            
            if topleftTextField == nil {
                topleftTextField = NSTextField(frame: NSRect(x: frame.minX + 10.0, y: frame.maxY - 20.0, width: 100.0, height: 20.0))
                topleftTextField?.cell?.title = "\(_mandelbrotRect.topLeft)"
                topleftTextField?.textColor = .white
                topleftTextField?.isSelectable = false
                topleftTextField?.alignment = .center
                addSubview(topleftTextField!)
            }
            
            topleftTextField?.cell?.title = "\(_mandelbrotRect.topLeft)"
            
            if bottomrightTextField == nil {
                bottomrightTextField = NSTextField(frame: NSRect(x: frame.maxX - 120.0, y: frame.minY + 10.0, width: 100.0, height: 20.0))
                bottomrightTextField?.cell?.title = "\(_mandelbrotRect.bottomRight)"
                bottomrightTextField?.textColor = .white
                bottomrightTextField?.isSelectable = false
                bottomrightTextField?.alignment = .center
                addSubview(bottomrightTextField!)
            }
            
            bottomrightTextField?.cell?.title = "\(_mandelbrotRect.bottomRight)"
        }
        get {
            return _mandelbrotRect
        }
    }
    
    var _rectScale: CGFloat = 1.0
    var rectScale: Double {
        get {
            return Double(_rectScale)
        }
        set {
            _rectScale = CGFloat(newValue)
            
            if scaleTextField == nil {
                scaleTextField = NSTextField(frame: NSRect(x: frame.maxX - 70.0, y: frame.maxY - 20.0, width: 50.0, height: 20.0))
                scaleTextField?.cell?.title = "\(rectScale)"
                scaleTextField?.textColor = .white
                scaleTextField?.isSelectable = false
                scaleTextField?.alignment = .center
                addSubview(scaleTextField!)
            }
            
            scaleTextField?.cell?.title = "\(rectScale)"
        }
    }
    
    let blockiness: CGFloat = 0.5 // pick a value from 0.25 to 5.0
    let colorCount = 2000
    var colorSet : Array<NSColor> = Array()
    
    var topleftTextField: NSTextField?
    var bottomrightTextField: NSTextField?
    var scaleTextField: NSTextField?
    
    var mandelbrotImage: NSImage? {
        didSet {
            needsDisplay = true
        }
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        mandelbrotImage?.draw(at: .zero, from: bounds, operation: .sourceOver, fraction: 1.0)
        
        let bpath = NSBezierPath(rect: selectRect)
        bpath.lineWidth = 2.0
        selectRectColor.set()
        bpath.stroke()
        
        //topleftTextField?.draw(dirtyRect)
        //let bpath = NSBezierPath(rect: selectRect)
        //bpath.lineWidth = 2.0

        //print("selectRectColor = \(selectRectColor)")
        //selectRectColor.set()
        //bpath.stroke()
        
    }
    
    func initializeColors() {
        if colorSet.count < 2 {
            colorSet = Array()
            for c in 0...colorCount {
                let c_f = CGFloat(c)
                colorSet.append(NSColor(hue: CGFloat(abs(sin(c_f/30.0))), saturation: 1.0, brightness: c_f/100.0 + 0.8, alpha: 1.0))
            }
        }
    }

    override func mouseDragged(with event: NSEvent) {
        if (NSColor.yellow == selectRectColor) {
            selectRect.origin = CGPoint(x: selectRect.origin.x + event.deltaX, y: selectRect.origin.y - event.deltaY)
            //delegate?.update(rect: selectRect)
            self.needsDisplay = true
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        guard let rectInWindow = self.superview?.convert(selectRect, to: nil) else {
            return
        }
        
        if (rectInWindow.contains(event.locationInWindow)) {
            selectRectColor = NSColor.yellow
            self.needsDisplay = true
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if (NSColor.yellow == selectRectColor) {
            selectRectColor = NSColor.white
            self.needsDisplay = true
        }
    }
}
