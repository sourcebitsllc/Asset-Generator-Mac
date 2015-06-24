//
//  AssetGenerator.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/3/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

enum GenerationState {
    case Progress(Float)
    case Assets(Int)
}

class AssetGenerator {
    typealias AssetGeneratorObserver = Signal<GenerationState, AssetGeneratorError>.Observer
    
    func generateAssets(source: [Asset], target: Path)(observer: AssetGeneratorObserver, completion: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            sendNext(observer, .Progress(10))
            let report = self.moveAssetsAndPrepareReport(source, destination: target)
            sendNext(observer, .Progress(50))
            self.reticulateReportAndDeploy(report)
            sendNext(observer, .Progress(95))
            sendNext(observer, .Assets(source.count))
            sendCompleted(observer)
            completion()
        }
    }

    /// :param: key: Path the asset `AssetSet` destination.
    /// :param: value: [Asset] The assets belonging to the said deestination.
    private typealias AssetsReport = [Path: [Asset]]
    
    private func reticulateReportAndDeploy(rep: AssetsReport) {
        for (path, assets) in rep {
            let destinationJSON = path + "Contents.json"
            
            if NSFileManager.defaultManager().fileExistsAtPath(destinationJSON) {
                var json = JSON.readJSON(destinationJSON) as! NSMutableDictionary
                let existingJSONImages = AssetAttribute.sanitizeJSON(json["images"] as! [JSONDictionary])

                updateAttributesWithAssets(existingJSONImages, assets: assets)
                    |> XCAssetsJSON.updateImagesValue(json)
                    |> JSON.writeJSON(to: destinationJSON)
                
            } else {
                assets.map { AssetMetaData.create($0).attributes.serialized }
                    |> XCAssetsJSON.createJSONDefaultWrapper
                    |> JSON.writeJSON(to: destinationJSON)
            }
        }
    }
    
    
    
    private func moveAssetsAndPrepareReport(assets: [Asset], destination: Path) -> AssetsReport {
        // Find all images in our source folder.
        var assetsPerDestination: [Path: [Asset]] = [:]
        for asset in assets {
            let path = computeEnclosingSet(asset, target: destination)
            assetsPerDestination[path] = (assetsPerDestination[path] ?? []) + [asset]
            
             //If .* doesnt exist, create it.
            FileSystem.createDirectoryIfMissing(path)
             //Compute the images' final location and proceed to copy.
            let finalImageDestination = path + asset.name
            FileSystem.copy(file: asset.fullPath, toLocation: finalImageDestination)
        }
        
        return assetsPerDestination
    }
    
    func computeEnclosingSet(asset: Asset, target: Path) -> Path {
        switch asset.type {
        case .Image:
            let subddirectory = asset.relativePath.stringByDeletingLastPathComponent
            let cleanSubDirectory = subddirectory.replace([".", ":"], withCharacter: "_")
            return target + cleanSubDirectory + "/" + asset.enclosingSet + "/"
        case .LaunchImage, .Icon:
            return target.removeTrailingSlash() + "/" + asset.enclosingSet + "/"
        }
    }
    
    
    private func updateAttributesWithAssets(list: [SerializedAssetAttribute], assets: [Asset]) -> [SerializedAssetAttribute] {
        var newJSON = list
        for i in assets {
            let image = AssetMetaData.create(i)
            let attributes = image.attributes
            let comparator = image.comparator
            
            // If we find a "matching" entry for image, update its name to new image. If not, add new image to json.
            if var entry = list.filter(comparator).first, let index = find(newJSON as [XCAssetsJSONDictionary], entry) {
                newJSON.removeAtIndex(index)
                entry[SerializedAssetAttributeKeys.Filename] = attributes.filename
                newJSON.insert(entry, atIndex: index)
            } else {
                newJSON.append(attributes.serialized)
            }
        }
        
        return newJSON
    }
}