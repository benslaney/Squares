//
//  NSColor.swift
//  Squares
//
//  Created by bongo on 10/07/2016.
//  Copyright © 2016 ben. All rights reserved.

// Usage
// NSColor.hexColor(0xff0000, alpha: 0.8)
// NSColor.hexColor(0xff0000)
// NSColor.hexColor(0xff0000).CGColor
// http://stackoverflow.com/questions/35240607/get-cgcolor-from-hex-string-in-swift-os-x

import Cocoa

/**
 * A NSColor extension
 **/
public extension NSColor {
    
    /**
     Returns an NSColor instance from the given hex value
     
     - parameter rgbValue: The hex value to be used for the color
     - parameter alpha:    The alpha value of the color
     
     - returns: A NSColor instance from the given hex value
     */
    public class func hexColor(rgbValue: Int, alpha: CGFloat = 1.0) -> NSColor {
        
        return NSColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green:((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue:((CGFloat)(rgbValue & 0xFF))/255.0, alpha:alpha)
        
    }
    
}