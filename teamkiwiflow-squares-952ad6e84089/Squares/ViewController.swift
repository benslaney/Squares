import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var imageViewOutlet: NSImageView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var squareCounterLabel: NSTextField!
    @IBOutlet weak var imageCountLabel: NSTextField!
    @IBOutlet weak var buttonLoadDataSet: NSButtonCell!
    @IBOutlet weak var filenameLabel: NSTextField!
    @IBOutlet weak var buttonDelete: NSButton!
    @IBOutlet weak var buttonNext: NSButton!
    @IBOutlet weak var buttonPrev: NSButton!
    @IBOutlet weak var labelImageCounter: NSTextField!
    @IBOutlet weak var labelFileName: NSTextField!
    @IBOutlet weak var labelEditSquare: NSTextField!
    
    @IBOutlet weak var buttonNudgeUp: NSButton!
    @IBOutlet weak var buttonNudgeLeft: NSButton!
    @IBOutlet weak var buttonNudgeDown: NSButton!
    @IBOutlet weak var buttonNudgeRight: NSButton!
    @IBOutlet weak var labelKeyToggles: NSTextField!

    var idlPathString = String()
    var index = -1;
    var lastWindowTouched: NSWindow = NSWindow()
    let nc = NSNotificationCenter.defaultCenter()
    
    func printValue(notification:NSNotification) {
    }
    
    func CGRectFlipped(rect: CGRect, bounds: CGRect) -> CGRect {
                return    CGRectMake(CGRectGetMinX(rect),
                          CGRectGetMaxY((bounds)) - CGRectGetMaxY(rect),
                          CGRectGetWidth(rect),
                          CGRectGetHeight(rect));
    }
    
    override func mouseDown(theEvent: NSEvent) {
        var click: CGPoint?
        click = theEvent.locationInWindow
        
        // don;t create squares outsize of scroll area
        if(click!.x > scrollView.visibleRect.width) {
            return
        }
        
        if(idlPathString == "") {
            return
        }
        
        var windowSize : NSSize = NSSize()
        if(lastWindowTouched.frame.height < 200 && lastWindowTouched.frame.height > 50 && lastWindowTouched.frame.width < 200 && lastWindowTouched.frame.width > 50) {
            windowSize.height = lastWindowTouched.frame.height
            windowSize.width = lastWindowTouched.frame.width
        } else {
            windowSize.height = 50
            windowSize.width = 50
        }
        let rect : NSRect = (view.window?.convertRectToScreen(NSMakeRect(click!.x-windowSize.width + (windowSize.width/2), click!.y - (windowSize.height/2), windowSize.width, windowSize.height)))!
        let newWindow = createNewWindow(rect)

        view.window?.addChildWindow(newWindow, ordered: NSWindowOrderingMode.Above)
        
        lastWindowTouched = newWindow
        updateidlFile()
    }
    
    override func touchesBeganWithEvent(event: NSEvent) {
    }
    
    override func flagsChanged(theEvent: NSEvent) {
        switch theEvent.modifierFlags.intersect(.DeviceIndependentModifierFlagsMask) {
        case NSEventModifierFlags.ShiftKeyMask :
            Swift.print("shift key is pressed")
            switchArrowButtons(1)
        case NSEventModifierFlags.ControlKeyMask:
            Swift.print("control key is pressed")
        case NSEventModifierFlags.AlternateKeyMask :
            Swift.print("option key is pressed")
            switchArrowButtons(1)
        case NSEventModifierFlags.CommandKeyMask:
            Swift.print("Command key is pressed")
        default:
            Swift.print("no key or more than one is pressed")
            switchArrowButtons(0)
        }
    }
    
    @IBAction func leftArrowClicked(sender: AnyObject) {
        let myidl = idl.init(idlpath: idlPathString, index: index-1)
        if(myidl.idl.count > 0) {
            index = index - 1
            loadImage(index)
            loadAndDisplayRects(index)
        }
        
    }
    
    @IBAction func rightArrowClicked(sender: AnyObject) {
        let myidl = idl.init(idlpath: idlPathString, index: index+1)
        if(myidl.idl.count > 0) {
            index = index + 1
            loadImage(index)
            loadAndDisplayRects(index)
        }
    }
    
    func updateImageCounter(count: Int, _ amount: Int) {
        imageCountLabel.stringValue = "\(count+1) / \(amount)";
        
        // hide show next prev buttons
        if(count == 0) {
            buttonPrev.hidden = true
        } else {
            buttonPrev.hidden = false
        }
        
        if((count+1) == amount) {
            buttonNext.hidden = true
        } else {
            buttonNext.hidden = false
        }
    }
    
    @IBAction func deleteClicked(sender: AnyObject) {
        lastWindowTouched.setIsVisible(false)
        lastWindowTouched.backgroundColor = NSColor.clearColor()
        view.window?.removeChildWindow(lastWindowTouched)
        self.updateidlFile()
    }
    
    @IBAction func addClicked(sender: AnyObject) {
        removeObservers()
        let myOpenDialog: NSOpenPanel = NSOpenPanel()
//        myOpenDialog.canChooseDirectories = true
        myOpenDialog.canChooseFiles = true
        myOpenDialog.runModal()
        
        
        if(myOpenDialog.URL != nil) {
            do {
                if(myOpenDialog.URL?.pathExtension == "idl") {
                    idlPathString = String.fromCString((myOpenDialog.URL?.fileSystemRepresentation)!)!
                    index = 0
                    loadImage(0)
                    loadAndDisplayRects(0)
//                    updateidlFile(false, idlFileURL: myOpenDialog.URL)
                } else {
                    let newidl = myOpenDialog.URL?.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("newidil.idl")
                    idlPathString = (newidl?.path)!
                    
                    if(!NSFileManager.defaultManager().fileExistsAtPath(newidl!.path!)) {
                        try "".writeToURL(newidl!, atomically: true, encoding: NSUTF8StringEncoding)
                    }
                    
                    loadImage(-1, imageURL: myOpenDialog.URL)
                    removeAllVisibleRects()
                    updateidlFile(true, idlFileURL: myOpenDialog.URL)
                }
            } catch let err as NSError {
                print(err)
            }
        }
        addObservers()
    }
    
    func isChildWindow(window: NSWindow) -> Bool {
        for thischild in (view.window?.childWindows)! {
            if(window == thischild) {
                return true
            }
        }
        return false
    }
    
    func windowModified(notification: NSNotification) {
        print ("window modified")

        var window = NSWindow()
        window = notification.object as! NSWindow
        
        if((window == self.view.window)) {
            //loadRects(index)
        } else {
            lastWindowTouched = window
            if(notification.name != NSWindowDidMoveNotification) {
                //Notifications are events that can occur at any time. This notification fires while the user is resizing the main window for the child windows.
                //While the user is resizing the main window, it also loads the rects from the file repeatedly. If you update the idlfile
                //while it's reading from the idl file some rects can get lost. Avoid that by just not updating the idlfile file for this event.
                if(isChildWindow(window)) {
                    //the open file dialog triggers this too, and you dont want to try to update the .idl file while that's going on. So here's another filter
                    updateidlFile()
                }
            }
        }
        
        // catch main window resize, update visable squares
        if(!isChildWindow(window)) {
            loadAndDisplayRects(index) 
        }
    }
  
    // todo: find better way to store data when user scrolls
    func saveData() {
        updateidlFile()
    }
    
    func scrollViewScrolled() {
        loadAndDisplayRects(index)
    }
    
    func scrollViewScrolledAfterTimer(timer : NSTimer) {
        loadAndDisplayRects(index)
        timer.invalidate()
    }
    
    func pausedScrollViewScrolled() {
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(ViewController.scrollViewScrolledAfterTimer(_:)), userInfo: nil, repeats: false)
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(saveData), name: NSScrollViewWillStartLiveScrollNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(scrollViewScrolled), name: NSScrollViewDidEndLiveScrollNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pausedScrollViewScrolled), name:"scrolling", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(windowModified), name: NSWindowDidMoveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(windowModified), name: NSWindowDidResizeNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(windowModified), name: NSWindowDidBecomeKeyNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(noWindowSelected(_:)), name:"noWindowSelected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(windowSelected(_:)), name:"windowSelected", object: nil)
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSScrollViewWillStartLiveScrollNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSScrollViewDidEndLiveScrollNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSWindowDidMoveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSWindowDidResizeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSWindowDidBecomeKeyNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "noWindowSelected", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "windowSelected", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "scrolling", object: nil)
    }
    
    override func viewDidAppear() {
        addObservers()
        showHideFileButtons(0)
        
        NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) {
            (aEvent) -> NSEvent? in
            self.keyDown(aEvent)
            return aEvent
        }
        
        NSEvent.addLocalMonitorForEventsMatchingMask(.FlagsChangedMask) { (theEvent) -> NSEvent! in
            self.flagsChanged(theEvent)
            return theEvent
        }
    }
    
    func updateidlFile(createNew: Bool? = false, idlFileURL: NSURL? = nil) {
        if(idlPathString.characters.count <= 0) { return }
        let myidl = idl.init(idlpath: idlPathString, index: index)
        var allRectsForImage : Array<Array<Float>> = []
        allRectsForImage = self.getAllVisibleRects()
        
        var imagePath : String = String()
        if(createNew == true) {
            imagePath = (idlFileURL!.URLByDeletingLastPathComponent?.lastPathComponent)! + "/" + idlFileURL!.lastPathComponent!
            index = myidl.update(idlPathString, index: -1, rects: allRectsForImage, inImagePath:imagePath)
        } else {
            myidl.update(idlPathString, index: index, rects: allRectsForImage, inImagePath:nil)
        }
        Swift.print("Saved")
        updateCounter()
    }
    
    func loadImage(index: Int, imageURL:NSURL? = nil) {
        var image : NSImage?
        if(index != -1) {
            let myidl = idl.init(idlpath: idlPathString, index: index)
            let lazyMapCollection1 = myidl.idl.keys
            let keys = Array(lazyMapCollection1)
            let baseFolder : NSURL = (NSURL(fileURLWithPath: idlPathString).URLByDeletingLastPathComponent)!
            
            if(keys.count == 0) { return }
            if(!NSFileManager.defaultManager().fileExistsAtPath((baseFolder.URLByAppendingPathComponent(keys[0]).path)!)) { return }
            
            image = NSImage(contentsOfURL:baseFolder.URLByAppendingPathComponent(keys[0]))!
            
            updateFileName(myidl.getCurrentImage())
        } else {
            if(imageURL != nil && NSFileManager.defaultManager().fileExistsAtPath((imageURL?.path)!)) {
                image = NSImage(contentsOfURL:imageURL!)!
            }
        }
        if(image != nil) {
            imageViewOutlet.frame = NSMakeRect(0,0,image!.size.width,image!.size.height)
            imageViewOutlet.image = image
        }
        
        showHideFileButtons(1)
    }
    
    func getAllVisibleRects() -> [[Float]] {
        var allRectsForImage : Array<Array<Float>> = []
        var i : Int = 0
        for thischild in (view.window?.childWindows)! {
            var thisRect : Array<Float> = []
            var convertedRect = thischild.frame
            
            convertedRect = (imageViewOutlet?.convertRect(convertedRect, fromView:nil))!
            convertedRect = (view.window?.convertRectFromScreen(convertedRect))!
            convertedRect = CGRectFlipped(convertedRect, bounds: (imageViewOutlet.frame))
            
            thisRect.append( Float(convertedRect.minX+1) )
            thisRect.append( Float(convertedRect.minY) )
            thisRect.append( Float(convertedRect.width + convertedRect.minX+1) )
            thisRect.append( Float(convertedRect.height + convertedRect.minY) )
            
            i = i + 4
            allRectsForImage.append(thisRect)
        }
        return allRectsForImage
    }
    
    func removeAllVisibleRects() {
        removeObservers()
        if(idlPathString.characters.count <= 0) { return }
        for thischild in (view.window?.childWindows)! {
            thischild.backgroundColor = NSColor.clearColor()
            view.window?.removeChildWindow(thischild)
        }
        addObservers()
    }
    
    func loadAndDisplayRects(index: Int) {
        removeObservers()
        if(idlPathString.characters.count <= 0) { return }
        for thischild in (view.window?.childWindows)! {
            thischild.backgroundColor = NSColor.clearColor()
            view.window?.removeChildWindow(thischild)
        }
        let myidl = idl.init(idlpath: idlPathString, index: index)
        let lazyMapCollection = myidl.idl.values
        let componentArray = Array(lazyMapCollection)
        
        if(componentArray.count == 0) { return }
        
        for thisrect in componentArray[0] {
            let arect : NSRect = NSMakeRect(CGFloat(thisrect[0]),CGFloat(thisrect[1]),CGFloat(thisrect[2]),CGFloat(thisrect[3]))
            var convertedRect = NSMakeRect(arect.minX, arect.minY, arect.width-arect.minX, arect.height-arect.minY)
            
            //convert the rect to the imageViewOutlet space
            convertedRect = (imageViewOutlet?.convertRect(convertedRect, fromView:nil))!

            //fucking kill me
            convertedRect = NSMakeRect(arect.minX-imageViewOutlet.visibleRect.minX, convertedRect.minY, convertedRect.width, convertedRect.height)
            
            //the idl file has the coordinates as top-left based. The imageOutletView has them as bottom-left based. Flip that
            convertedRect = CGRectFlipped(convertedRect, bounds: (imageViewOutlet.frame))
            
            //now we're actually going to make the squares by drawing entire windows that look like squares instead of custom squares.
            //Windows use the coordinate space of the whole screen, so convert it to that before drawing
            convertedRect = (view.window?.convertRectToScreen(convertedRect))!
            
            //draw that window I was just talking about
            let newWindow: CustomWindow = createNewWindow(convertedRect)
            
            
            // check if square is off the side of the scroll window
            // note flip Y as above
            if( CGFloat(thisrect[0]) < scrollView.contentView.bounds.origin.x
                || CGFloat(thisrect[0]) > scrollView.contentView.bounds.origin.x+scrollView.visibleRect.width
                || CGFloat(thisrect[1]) < imageViewOutlet.frame.maxY-scrollView.visibleRect.height-scrollView.contentView.bounds.origin.y
                || CGFloat(thisrect[1]) > imageViewOutlet.frame.maxY-scrollView.contentView.bounds.origin.y) {
                    // HIDE WINDOW by alpha so it's still there for when you save the output file
                     newWindow.backgroundColor = NSColor.hexColor(0xff0000, alpha: 0.0)
                    // send it to the back!
                    view.window?.addChildWindow(newWindow, ordered: NSWindowOrderingMode.Below)
            } else {
                view.window?.addChildWindow(newWindow, ordered: NSWindowOrderingMode.Above)
            }
        }

        // update counters
        updateImageCounter(index, myidl.getTotalImageCount(idlPathString))
        updateCounter()
        
        addObservers()
    }
    
    override func viewDidLayout() {
    }
    
    override func viewDidLoad() {
        //FontAwesome buttons.font = NSFont(name: "FontAwesome", size: 16)
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .Center
        buttonLoadDataSet.attributedTitle = NSAttributedString(string: "\u{f115}", attributes: [ NSForegroundColorAttributeName : NSColor.hexColor(0x428BCA), NSParagraphStyleAttributeName : pstyle, NSFontAttributeName : NSFont(name: "FontAwesome", size: 20)!])
        
        let buttonNextPstyle = NSMutableParagraphStyle()
        buttonNextPstyle.alignment = .Right
        buttonNext.attributedTitle = NSAttributedString(string: "\u{f0a9}", attributes: [ NSForegroundColorAttributeName : NSColor.hexColor(0x428BCA), NSParagraphStyleAttributeName : buttonNextPstyle, NSFontAttributeName : NSFont(name: "FontAwesome", size: 20)!])
        
        let buttonPrevPstyle = NSMutableParagraphStyle()
        buttonPrevPstyle.alignment = .Left
        buttonPrev.attributedTitle = NSAttributedString(string: "\u{f0a8}", attributes: [ NSForegroundColorAttributeName : NSColor.hexColor(0x428BCA), NSParagraphStyleAttributeName : buttonPrevPstyle, NSFontAttributeName : NSFont(name: "FontAwesome", size: 20)!])
        
        buttonNudgeUp.font = NSFont(name: "FontAwesome", size: 14)
        buttonNudgeUp.title = "\u{f062}"
        buttonNudgeRight.font = NSFont(name: "FontAwesome", size: 14)
        buttonNudgeRight.title = "\u{f061}"
        buttonNudgeDown.font = NSFont(name: "FontAwesome", size: 14)
        buttonNudgeDown.title = "\u{f063}"
        buttonNudgeLeft.font = NSFont(name: "FontAwesome", size: 14)
        buttonNudgeLeft.title = "\u{f060}"
    }

    func createNewWindow(rect: NSRect) -> CustomWindow {
        let newWindow = CustomWindow(contentRect: rect, styleMask:
                                 NSResizableWindowMask|NSClosableWindowMask|NSFullSizeContentViewWindowMask,
                                 backing: NSBackingStoreType.Buffered, defer: false)
        newWindow.opaque = false
        newWindow.hasShadow = false
        newWindow.movableByWindowBackground = true
        newWindow.showsResizeIndicator = false

//        newWindow.contentView?.alphaValue=0.0
        newWindow.backgroundColor = NSColor(calibratedHue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 0.35)
        
        return newWindow
    }
    
    override var representedObject: AnyObject? {
        didSet {
        }
    }

    func updateCounter() {
        let count = getAllVisibleRects().count
        squareCounterLabel.stringValue = "COUNT: \(count)";
    }

    // show / hide selected window scripts
    func noWindowSelected(notification: NSNotification){
        Swift.print("noWindow note")
        showHideNudgeButtons(0)
        updateidlFile()
    }

    func windowSelected(notification: NSNotification) {
        Swift.print("Window selected note")
        showHideNudgeButtons(1)
    }

    func methodOfReceivedNotification(notification: NSNotification){
        //Take Action on Notification
    }

    func updateFileName(filename: NSString){
        
        let ext  : NSString = filename.lastPathComponent
        filenameLabel.stringValue = ext as String
    }

    func showHideFileButtons(show: Int) {
        if(show == 1) {
            buttonNext.hidden           = false
            buttonPrev.hidden           = false
            labelImageCounter.hidden    = false
            labelFileName.hidden        = false
        } else { // hide buttons
            buttonDelete.hidden         = true
            buttonNext.hidden           = true
            buttonPrev.hidden           = true
            labelImageCounter.hidden    = true
            labelFileName.hidden        = true
            
            showHideNudgeButtons(0)
        }
    }

    func showHideNudgeButtons(show: Int) {
        if(show == 1) {
            buttonDelete.hidden         = false
            buttonNudgeUp.hidden        = false
            buttonNudgeLeft.hidden      = false
            buttonNudgeDown.hidden      = false
            buttonNudgeRight.hidden     = false
            labelKeyToggles.hidden      = false
            labelEditSquare.hidden      = false
        } else {
            buttonDelete.hidden         = true
            buttonNudgeUp.hidden        = true
            buttonNudgeLeft.hidden      = true
            buttonNudgeDown.hidden      = true
            buttonNudgeRight.hidden     = true
            labelKeyToggles.hidden      = true
            labelEditSquare.hidden      = true
        }
    }
    
    func switchArrowButtons(direction: Int) {
        if(direction == 0) {
            buttonNudgeUp.title = "\u{f062}"
            buttonNudgeRight.title = "\u{f061}"
            buttonNudgeDown.title = "\u{f063}"
            buttonNudgeLeft.title = "\u{f060}"
        } else {
            buttonNudgeUp.title = "\u{f176}"
            buttonNudgeRight.title = "\u{f178}"
            buttonNudgeDown.title = "\u{f175}"
            buttonNudgeLeft.title = "\u{f177}"
        }
    }
}
