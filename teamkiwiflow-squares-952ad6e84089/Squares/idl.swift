import Foundation

class idl  {
    var idl : Dictionary<String, Array<Array<Float>>>
    var currentImage = ""
    
    init(idlpath: String, index: Int) {
        self.idl = [:]
        
        do {
            if(index < 0) { return }
            let data = try String(contentsOfFile:idlpath, encoding: NSUTF8StringEncoding)
            if(data.characters.count == 0) { print("no data"); return }
            var lines = data.componentsSeparatedByString("\n")
            if(index > lines.count-1 || lines[index].characters.count == 0) { return }
            let imagePath = lines[index].componentsSeparatedByString("\"")[1]
            self.currentImage = imagePath
            var words = lines[index].substringFromIndex(imagePath.characters.count).componentsSeparatedByString(" ")
            
            var coords = Array<Array<Float>>()
            var thisRect : Array<Float> = []
            var allRectsForImage : Array<Array<Float>> = []
            let numberFormatter = NSNumberFormatter()
            var i : Int = 1
            
            while i+4 <= words.count {
                var number : NSNumber
                let chars : NSCharacterSet = NSCharacterSet(charactersInString: "(),")
                
                number = numberFormatter.numberFromString(words[i].componentsSeparatedByCharactersInSet(chars)[1])!
                thisRect.append(number.floatValue)
                number = numberFormatter.numberFromString(words[i+1].componentsSeparatedByCharactersInSet(chars)[0])!
                thisRect.append(number.floatValue)
                number = numberFormatter.numberFromString(words[i+2].componentsSeparatedByCharactersInSet(chars)[0])!
                thisRect.append(number.floatValue)
                number = numberFormatter.numberFromString(words[i+3].componentsSeparatedByCharactersInSet(chars)[0])!

                thisRect.append(number.floatValue)
                coords.append(thisRect)
                allRectsForImage.append(thisRect)
                thisRect.removeAll()
                
                i = i + 4
            }

            self.idl[imagePath] = allRectsForImage

        } catch let err as NSError {
            print(err)
        }
    }
    
    func getCurrentImage() -> String {
        return currentImage
    }
    
    func getTotalImageCount(idlpath: String) -> Int {
        do {
            var data : String = String()
            var lines : Array<String> = Array()
            
            if(NSFileManager.defaultManager().fileExistsAtPath(idlpath)) {
                data = try String(contentsOfFile:idlpath, encoding: NSUTF8StringEncoding)
                if(data.characters.count > 0) {
                    lines = data.componentsSeparatedByString("\n")
                    return lines.count
                }
            }
        } catch let err as NSError {
            print(err)
        }
        return -1
    }

    func getIndexForImagePath(imagePath: String, index: Int, array: [String]) -> Int {
        var i : Int = 0
        var returnValue : Int = -1
        
        for thispath in array {
            if(thispath.containsString(imagePath)) {
                returnValue = i
                break
            }
            i = i + 1
        }
        
        return returnValue
    }
    
    func update(idlpath: String, index: Int, rects: [[Float]], inImagePath:String?) -> Int {
        var verifiedIndex : Int = index
        do {
            var data : String = String()
            var lines : Array<String> = Array()
            var theLine : String = String()
            var imagePath : String = String()
            
            if(NSFileManager.defaultManager().fileExistsAtPath(idlpath)) {
                data = try String(contentsOfFile:idlpath, encoding: NSUTF8StringEncoding)
                if(data.characters.count > 0) {
                    lines = data.componentsSeparatedByString("\n")
                    if(index != -1 && lines[index].characters.count > 0) {
                        imagePath = lines[index].componentsSeparatedByString("\"")[1]
                    }
                }
            }
            
            if(imagePath.characters.count == 0) {
                if(inImagePath == nil) {
                    print("inImagePath wasn't there for us when we needed it");
                    return -1
                }
                imagePath = inImagePath!
            }
            
            verifiedIndex = getIndexForImagePath(imagePath, index:index, array:lines)

            theLine = theLine + "\"\(imagePath)\": "
            for thisrect in rects {
                theLine = theLine + "(\(thisrect[0]), \(thisrect[1]), \(thisrect[2]), \(thisrect[3]))"
                if(!(thisrect == rects.last!)) {
                    theLine = theLine + ", "
                } else {
                    theLine = theLine+";"
                }
            }
            
            if(verifiedIndex != -1) {
                lines.removeAtIndex(verifiedIndex)
                lines.insert(theLine, atIndex: verifiedIndex)
            } else {
                lines.append(theLine)
                verifiedIndex = lines.count-1
            }
            
            let joined = lines.joinWithSeparator("\n")
            try joined.writeToFile(idlpath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let err as NSError {
            print(err)
        }
        
        return verifiedIndex
    }
}

extension String {
    func substringFromIndex(index: Int) -> String {
        if (index < 0 || index > self.characters.count) {
            print("index \(index) out of bounds")
            return ""
        }
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }
}
