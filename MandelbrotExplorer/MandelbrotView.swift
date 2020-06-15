//
//  AnotherMandelbrotView.swift
//  MandelbrotExplorer
//
//  Created by Jae Seung Lee on 6/1/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import Cocoa

class MandelbrotView: NSView {
    var selectRect = CGRect(x: 60, y: 100, width: 100, height: 100)
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
       
        let bpath = NSBezierPath(rect: selectRect)
        bpath.lineWidth = 2.0
        selectRectColor.set()
        bpath.stroke()
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
            delegate?.update(rect: selectRect)
            self.needsDisplay = true
        }
    }
}
