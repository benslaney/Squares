//
//  AppDelegate.swift
//  Squares
//
//  Created by ben on 17/05/16.
//  Copyright © 2016 ben. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
//        NSImageView hi = self.window?.contentViewController.imageviewoutlet
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("printValue", object: nil, userInfo: ["value" : "9"])
        
        // check fonts
//        let fontFamilyNames = NSFontManager.sharedFontManager().availableFontFamilies
//        print("avaialble fonts is \(fontFamilyNames)")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}

