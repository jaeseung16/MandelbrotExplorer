//
//  MandelbrotUIView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/5/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import UIKit

class MandelbrotUIView: UIView {
    var selectRect: CGRect?
    var selectRectColor = UIColor.white
    
    var id: MandelbrotID?
    //var delegate: MandelbrotViewDelegate?

    var mandelbrotImage: UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    //var topleftTextField: UITextField?
    //var bottomrightTextField: UITextField?
    //var scaleTextField: UITextField?
    
    var _mandelbrotRect: ComplexRect?
    
    var mandelbrotRect: ComplexRect {
        set {
            _mandelbrotRect = newValue
            
            /*
            if topleftTextField == nil {
                topleftTextField = UITextField(frame: NSRect(x: bounds.minX + 5.0, y: bounds.maxY - 20.0, width: 120.0, height: 20.0))
                topleftTextField?.cell?.title = "\(newValue.topLeft)"
                topleftTextField?.textColor = .white
                topleftTextField?.isSelectable = false
                topleftTextField?.alignment = .center
                addSubview(topleftTextField!)
            }
            
            
            topleftTextField?.cell?.title = "\(newValue.topLeft)"
            
            if bottomrightTextField == nil {
                bottomrightTextField = NSTextField(frame: NSRect(x: bounds.maxX - 125.0, y: bounds.minY + 10.0, width: 120.0, height: 20.0))
                bottomrightTextField?.cell?.title = "\(newValue.bottomRight)"
                bottomrightTextField?.textColor = .white
                bottomrightTextField?.isSelectable = false
                bottomrightTextField?.alignment = .center
                addSubview(bottomrightTextField!)
            }
            
            bottomrightTextField?.cell?.title = "\(newValue.bottomRight)"
            */
        }
        get {
            return _mandelbrotRect!
        }
    }
    
    var _rectScale: CGFloat = 1.0
    var rectScale: Double {
        get {
            return Double(_rectScale)
        }
        set {
            _rectScale = CGFloat(newValue)
            /*
            if scaleTextField == nil {
                scaleTextField = NSTextField(frame: NSRect(x: bounds.maxX - 55.0, y: bounds.maxY - 20.0, width: 50.0, height: 20.0))
                scaleTextField?.cell?.title = "⨉\(rectScale)"
                scaleTextField?.textColor = .white
                scaleTextField?.isSelectable = false
                scaleTextField?.alignment = .center
                addSubview(scaleTextField!)
            }
            
            scaleTextField?.cell?.title = "x\(rectScale)"
             */
        }
    }
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        mandelbrotImage?.draw(in: dirtyRect)
       
        guard let rect = selectRect else {
            return
        }
        
        let bpath = UIBezierPath(rect: rect)
        bpath.lineWidth = 2.0
        selectRectColor.set()
        bpath.stroke()
    }
    
    /*
    
    override func mouseDragged(with event: UIEvent) {
        guard let rect = selectRect else {
            return
        }
        
        if (NSColor.yellow == selectRectColor) {
            selectRect?.origin = CGPoint(x: rect.origin.x + event.deltaX, y: rect.origin.y - event.deltaY)
            //delegate?.update(rect: selectRect)
            self.needsDisplay = true
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        guard let rect = selectRect, let rectInWindow = self.superview?.convert(rect, to: nil) else {
            return
        }
        
        if (rectInWindow.contains(event.locationInWindow)) {
            selectRectColor = NSColor.yellow
            self.needsDisplay = true
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let rect = selectRect else {
            return
        }
        
        if (NSColor.yellow == selectRectColor) {
            selectRectColor = NSColor.white
            delegate?.update(rect: rect, in: self.id!)
            self.needsDisplay = true
        }
    }
     */
}
