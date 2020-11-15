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
        }
    }
    
    var sideLength: Int {
        get {
            return Int(self.frame.width)
        }
    }
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        mandelbrotImage?.draw(in: dirtyRect)
       
        guard let rect = _selectRect else {
            return
        }
        
        print("rect = \(rect)")
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
        print("gestureRecognizers: \(touch.gestureRecognizers)")
        
        let gestureRecognizers = touch.gestureRecognizers
        
        guard let rect = _selectRect else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        //print("rect: \(rect)")
        //print("touchLocation: \(touchLocation)")
        //print("rect.contains(touchLocation)? \((rect.contains(touchLocation)))")
        
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
                
                var minX = rect.minX + delta.x
                var minY = rect.minY + delta.y
                
                let maxX = rect.maxX + delta.x
                let maxY = rect.maxY + delta.y
                
                if (minX < 0 || maxX > bounds.width) {
                    minX = rect.minX
                }
                
                if (minY < 0 || maxY > bounds.height) {
                    minY = rect.minY
                }
                
                _selectRect?.origin = CGPoint(x: minX, y: minY)
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
    
    @IBAction func updateSelectRect(_ sender: UIPinchGestureRecognizer) {
        print("sender: \(sender)")
        switch (sender.state) {
        case .began:
            selectRectColor = UIColor.yellow
        case .changed:
            var size = sender.scale * selectRect.width
            if (size >= 0.05 * bounds.width && size <= 0.5 * bounds.width) {
                if (selectRect.minX + size >= bounds.width) {
                    size = bounds.width - selectRect.minX
                }
                if (selectRect.minY + size >= bounds.height) {
                    size = bounds.height - selectRect.minY
                }
                selectRect.size = CGSize(width: size, height: size)
            }
            sender.scale = 1.0
        case .ended:
            selectRectColor = UIColor.white
            delegate?.update(rect: selectRect, in: self.id!)
        case .cancelled:
            return
        case .possible:
            return
        case .failed:
            return
        @unknown default:
            return
        }
        self.setNeedsDisplay()
    }
    
}
