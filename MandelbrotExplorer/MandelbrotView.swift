//
//  AnotherMandelbrotView.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/1/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Cocoa

class MandelbrotView: NSView {
    var selectRect: CGRect?
    var selectRectColor = NSColor.white
    
    var delegate: MandelbrotViewDelegate?

    var mandelbrotImage: NSImage? {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        mandelbrotImage?.draw(at: .zero, from: bounds, operation: .sourceOver, fraction: 1.0)
       
        guard let rect = selectRect else {
            return
        }
        
        let bpath = NSBezierPath(rect: rect)
        bpath.lineWidth = 2.0
        selectRectColor.set()
        bpath.stroke()
    }
    
    override func mouseDragged(with event: NSEvent) {
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
            delegate?.update(rect: rect)
            self.needsDisplay = true
        }
    }
}
