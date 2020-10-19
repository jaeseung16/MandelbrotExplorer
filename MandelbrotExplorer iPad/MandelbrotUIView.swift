//
//  MandelbrotUIView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/5/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import UIKit

class MandelbrotUIView: UIView {
    var _selectRect: CGRect?
    var selectRect: CGRect {
        set {
            _selectRect = newValue
            self.setNeedsDisplay()
        }
        get {
            return _selectRect!
        }
    }
    
    var selectRectColor = UIColor.white
    
    var id: MandelbrotID?
    var delegate: MandelbrotViewDelegate?

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
       
        guard let rect = _selectRect else {
            return
        }
        
        let bpath = UIBezierPath(rect: rect)
        bpath.lineWidth = 2.0
        selectRectColor.set()
        bpath.stroke()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        print("touchesBegan: \(touch)")
        
        guard let rect = _selectRect else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        print("rect: \(rect)")
        print("touchLocation: \(touchLocation)")
        print("rect.contains(touchLocation)? \((rect.contains(touchLocation)))")
        
        if (rect.contains(touchLocation)) {
            selectRectColor = UIColor.yellow
            self.setNeedsDisplay()
        }
        
        /*
        guard let rect = selectRect, let rectInWindow = self.superview?.convert(rect, to: nil) else {
            return
        }
        
        if (rectInWindow.contains(event.locationInWindow)) {
            selectRectColor = UIColor.yellow
            self.setNeedsDisplay()
        }*/
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesMoved")
        
        guard let touch = touches.first else {
            return
        }
        
        guard let rect = _selectRect else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        if (rect.contains(previousLocation) && bounds.contains(touchLocation)) {
            if (UIColor.yellow == selectRectColor) {
                let delta = CGPoint(x: touchLocation.x - previousLocation.x, y: touchLocation.y - previousLocation.y)
                _selectRect?.origin = CGPoint(x: rect.origin.x + delta.x, y: rect.origin.y + delta.y)
                self.setNeedsDisplay()
            }            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded");

        guard let touch = touches.first else {
            return
        }
        
        guard let rect = _selectRect else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        print("touch.location(in: self)): \(touch.location(in: self)))")
        
        if (rect.contains(previousLocation) && bounds.contains(touchLocation)) {
            if (UIColor.yellow == selectRectColor) {
                let delta = CGPoint(x: touchLocation.x - previousLocation.x, y: touchLocation.y - previousLocation.y)
                _selectRect?.origin = CGPoint(x: rect.origin.x + delta.x, y: rect.origin.y + delta.y)
                selectRectColor = UIColor.white
                delegate?.update(rect: rect, in: self.id!)
                self.setNeedsDisplay()
            }
        }
    }
}
