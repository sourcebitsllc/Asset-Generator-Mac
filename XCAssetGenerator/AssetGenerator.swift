//
//  AssetGenerator.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/3/15.
//  Copyright (c) 2015 Pranav Shah. All rights reserved.
//

import Foundation

protocol ScriptProgessDelegate {
    func scriptDidStartExecutingScipt()
    func scriptFinishedExecutingScript()
    func scriptExecutingScript(progress: Int?)
}

enum AssetGenerationStatus {
    case Started
    case Finished
    case Ongoing(Int)
}

extension String {
    func replace(characters: [Character], withCharacter character: Character) -> String {
        return String(map(self) {
            if find(characters, $0) == nil {
                return $0
            } else {
                return character
            }
        })
    }
}

class AssetGenerator {
    
    var running: Bool
    var progressDelegate: ScriptProgessDelegate?
    
    init() {
        running = false
    }
    
    func executing() -> Bool {
        return running
    }
    
    func generateAssets(source: Path, target: Path) {
        let temp = source + ".XCAssetTemp/"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self.notifyDelegate(.Started)
            // Step 1
            FileSystem.deleteDirectory(temp)
            self.notifyDelegate(.Ongoing(5))
            NSFileManager.defaultManager().createDirectoryAtPath(temp, withIntermediateDirectories: false, attributes: nil, error: nil)
            self.notifyDelegate(.Ongoing(10))
            // Step 2
            self.populateTemporaryDirectory(source, temp: temp)
            self.notifyDelegate(.Ongoing(50))
            // Step 3
            self.integrateAssets(temp, target: target + "/")
            self.notifyDelegate(.Ongoing(95))
            // Step 4
            FileSystem.deleteDirectory(temp)
            self.notifyDelegate(.Finished)
        }
        
    }
    
    private func populateTemporaryDirectory(source: Path, temp: Path) {
        // Find all images in our source folder.
        let images = PathQuery.availableImages(from: source)
        notifyDelegate(.Ongoing(15))
        
        for image in images {
            
            let asset = Asset.create(image)
            
            // Compute the temporary XCAssets folder format for given image.
            var tempDest: Path!
            switch asset.type {
            case .Image:
                let path = image.stringByDeletingLastPathComponent + "/"
                let subddirectory = path.stringByReplacingOccurrencesOfString(source, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let cleanSubDirectory = subddirectory.replace([".", ":"], withCharacter: "_")
                tempDest = temp + cleanSubDirectory + asset.enclosingFolder + "/"
                
            case .Icon:
                fallthrough
            case .LaunchImage:
                tempDest = temp + asset.enclosingFolder + "/"
            }
            
            // Create the folder if it does not exist.
            FileSystem.createDirectoryIfMissing(tempDest)
            
            // Compute the temporary image location and grab a copy.
            let imageTemporaryLocation = tempDest + image.lastPathComponent
            FileSystem.copy(file: image, toLocation: imageTemporaryLocation)
            
        }
    }
    
    
    private func integrateAssets(temp: Path, target: Path) {
        let folders = PathQuery.availableAssetFolders(from: temp)
        notifyDelegate(.Ongoing(60))
        for folder in folders {
            let images = PathQuery.availableImages(from: folder)
            
            // Move Images First.
            for image in images {
                
                let dir = image.stringByDeletingLastPathComponent + "/"
                let path = dir.stringByReplacingOccurrencesOfString(temp, withString: target, options: NSStringCompareOptions.LiteralSearch, range: nil)
                var xcfolder = path + "/"
                
                // If .* doesnt exist, create it.
                FileSystem.createDirectoryIfMissing(xcfolder)
                
                // Compute the images' final location and proceed to copy.
                let finalImageDestination = xcfolder + image.lastPathComponent
                FileSystem.copy(file: image, toLocation: finalImageDestination)
            }
            
            // Create the accompanying JSON
            let destinationJSON = folder.stringByReplacingOccurrencesOfString(temp, withString: target, options: NSStringCompareOptions.LiteralSearch, range: nil) + "/Contents.json"
            
            //  If target JSON exists, merge new images into it. Else, Create new JSON with images
            if NSFileManager.defaultManager().fileExistsAtPath(destinationJSON) {
                
                let json = JSON.readJSON(destinationJSON)
                let existingJSONImages = json["images"] as [SerializedAssetAttribute]
                var newJSON = existingJSONImages
                
                for i in images {
                    let image = Asset.create(i)
                    let attributes = image.attributes
                    
                    // If we find a "matching" entry for image, update its name to new image. If not, add new image to json.
                    let comparator = image.comparator
                    var entry = (existingJSONImages as [SerializedAssetAttribute]).filter(comparator).first
                    
                    if var entry = entry {
                        entry["filename"] = attributes.filename
                        let index = find(newJSON as [JSONDictionary], entry)!
                        newJSON.removeAtIndex(index)
                        newJSON.insert(entry, atIndex: index)
                    } else {
                        newJSON.append(attributes.serialized)
                    }
                    
                }
                // Commit updates and write JSON.
                (json as NSMutableDictionary)["images"] = newJSON
                JSON.writeJSON(json, toFile: destinationJSON)
                
            } else {
                let imagesProperties: [SerializedAssetAttribute] = images.map {
                    return Asset.create($0).attributes.serialized
                }
                
                let json = JSON.createJSONDefaultWrapper(imagesProperties)
                JSON.writeJSON(json, toFile: destinationJSON)
            }
        }
    }
    
    private func notifyDelegate(progress: AssetGenerationStatus) {
        dispatch_async(dispatch_get_main_queue()) {
            switch progress {
            case .Started:
                self.running = true
                self.progressDelegate?.scriptDidStartExecutingScipt()
            case .Finished:
                self.running = false
                self.progressDelegate?.scriptFinishedExecutingScript()
            case .Ongoing(let p):
                self.progressDelegate?.scriptExecutingScript(p)
            }
        }
    }
}