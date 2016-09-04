//
//  scrollView.swift
//  Squares
//
//  Created by bongo on 18/07/2016.
//  Copyright © 2016 ben. All rights reserved.
//

import Cocoa

class CustomScrollView: NSScrollView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func scrollWheel(theEvent: NSEvent) {
        super.scrollWheel(theEvent)
        NSNotificationCenter.defaultCenter().postNotificationName("scrolling", object: nil)
    }
}
