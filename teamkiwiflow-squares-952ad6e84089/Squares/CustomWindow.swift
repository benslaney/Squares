import Cocoa

class CustomWindow: NSWindow {
    var shiftKeyPressed = false
    var optionKeyPressed = false

    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: false)
    }
    
    override func becomeKeyWindow() {
        super.becomeKeyWindow()
        Swift.print("became key")
        self.backgroundColor = NSColor(calibratedHue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 0.35) // blue
        NSNotificationCenter.defaultCenter().postNotificationName("windowSelected", object: nil)
    }
    
    override func resignKeyWindow() {
        super.resignKeyWindow()
        Swift.print("Resign key")
        self.backgroundColor = NSColor(calibratedHue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 0.35) // red
        NSNotificationCenter.defaultCenter().postNotificationName("noWindowSelected", object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeKeyWindow: Bool {
        return true
    }

    override func mouseDown(theEvent: NSEvent) {
    }

    override func mouseEntered(theEvent: NSEvent) {
        Swift.print("Mouse over")
        if(!keyWindow) {
            self.backgroundColor = NSColor(calibratedHue: 0.6, saturation: 1.0, brightness: 1.0, alpha: 0.35) // red
        }
    }
    
    override func mouseExited(theEvent: NSEvent) {
        if(!keyWindow) {
            self.backgroundColor = NSColor(calibratedHue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 0.35) // red
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        if(keyWindow) {
        // capture keys
//        Swift.print("\(theEvent.keyCode)")
            switch theEvent.keyCode {
            case 123:
                btnNudgeLeft(theEvent)
            case 125:
                btnNudgeDown(theEvent)
            case 124:
                btnNudgeRight(theEvent)
            case 126:
                btnNudgeUp(theEvent)
            default:
                return
            }
        }
    }
    
    override func flagsChanged(theEvent: NSEvent) {
        switch theEvent.modifierFlags.intersect(.DeviceIndependentModifierFlagsMask) {
        case NSEventModifierFlags.ShiftKeyMask :
            shiftKeyPressed = true
        case NSEventModifierFlags.ControlKeyMask:
            Swift.print("control key is pressed")
        case NSEventModifierFlags.AlternateKeyMask :
            Swift.print("option key is pressed")
            optionKeyPressed = true
        case NSEventModifierFlags.CommandKeyMask:
            Swift.print("Command key is pressed")
        default:
            shiftKeyPressed = false
            optionKeyPressed = false
        }
    }
    
    @IBAction func btnNudgeUp(sender: AnyObject) {
        if(shiftKeyPressed) {
            // grow
            self.setFrame(NSMakeRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height+1), display: true, animate: false)
        } else if(optionKeyPressed) {
            // move
            self.setFrame(NSMakeRect(self.frame.origin.x, self.frame.origin.y+1, self.frame.size.width, self.frame.size.height), display: true, animate: false)
        } else {
            // shrink
            self.setFrame(NSMakeRect(self.frame.origin.x, self.frame.origin.y+1, self.frame.size.width, self.frame.size.height-1), display: true, animate: false)
        }
    }
    
    @IBAction func btnNudgeRight(sender: AnyObject) {
        if(shiftKeyPressed) {
            // grow
            self.setFrame(NSMakeRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+1, self.frame.size.height), display: true, animate: false)
        } else if(optionKeyPressed) {
            // move
            self.setFrame(NSMakeRect(self.frame.origin.x+1, self.frame.origin.y, self.frame.size.width, self.frame.size.height), display: true, animate: false)
        } else {
            // shrink
            self.setFrame(NSMakeRect(self.frame.origin.x+1, self.frame.origin.y, self.frame.size.width-1, self.frame.size.height), display: true, animate: false)
        }
    }
    
    
    @IBAction func btnNudgeDown(sender: AnyObject) {
        if(shiftKeyPressed) {
            // grow
            self.setFrame(NSMakeRect(self.frame.origin.x, self.frame.origin.y-1, self.frame.size.width, self.frame.size.height+1), display: true, animate: false)
        } else if(optionKeyPressed) {
            // move
            self.setFrame(NSMakeRect(self.frame.origin.x, self.frame.origin.y-1, self.frame.size.width, self.frame.size.height), display: true, animate: false)
        } else {
            // shrink
            self.setFrame(NSMakeRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height-1), display: true, animate: false)
        }
    }
    
    
    @IBAction func btnNudgeLeft(sender: AnyObject) {
        if(shiftKeyPressed) {
            // grow
            self.setFrame(NSMakeRect(self.frame.origin.x-1, self.frame.origin.y, self.frame.size.width+1, self.frame.size.height), display: true, animate: false)
        } else if(optionKeyPressed) {
            // move
            self.setFrame(NSMakeRect(self.frame.origin.x-1, self.frame.origin.y, self.frame.size.width, self.frame.size.height), display: true, animate: false)
        } else {
            // shrink
            self.setFrame(NSMakeRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width-1, self.frame.size.height), display: true, animate: false)
        }
    }    
}

