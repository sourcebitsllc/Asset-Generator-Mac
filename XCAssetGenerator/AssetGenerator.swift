//
//  AssetGenerator.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/3/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import ReactiveCocoa

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

    /// :param: key: Path the assets' `AssetSet` destination.
    /// :param: value: [Asset] The assets belonging to the said deestination.
    private typealias AssetsReport = [Path: [Asset]]
    
    private func reticulateReportAndDeploy(rep: AssetsReport) {
        for (path, assets) in rep {
            let destinationJSON = path + "Contents.json"
            
            if var json = JSON.readJSON(destinationJSON) as? XCAssetsJSONWrapper,
                let imagesJSON = json["images"] as? [XCAssetsJSON] {
                    sanitizeJSON(imagesJSON)
                        |> updateAttributesWithAssets(assets)
                        |> XCAssetsJSONHelper.updateImagesValue(json)
                        |> JSON.writeJSON(to: destinationJSON)
                
            } else {
                assets.map { AssetMetaData.create($0).attributes.serialized }
                    |> XCAssetsJSONHelper.createJSONDefaultWrapper
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
            return String.pathWithComponents([target, cleanSubDirectory, asset.enclosingSet]) + "/"
        case .LaunchImage, .Icon:
            return String.pathWithComponents([target, asset.enclosingSet]) + "/"
        }
    }
    
    
    private func updateAttributesWithAssets(assets: [Asset])(assetsJSON: [XCAssetsJSON]) -> [XCAssetsJSON] {
        var newJSON = assetsJSON
        for i in assets {
            let image = AssetMetaData.create(i)
            let attributes = image.attributes
            let comparator = image.comparator
            
            // If we find a "matching" entry for image, update its name to new image. If not, add new image to json.
            if var entry = assetsJSON.filter(comparator).first,
                let index = find(newJSON as [NSDictionary], entry) {
                    newJSON.removeAtIndex(index)
                    entry[XCAssetsJSONKeys.Filename] = attributes.filename
                    newJSON.insert(entry, atIndex: index)
            } else {
                newJSON.append(attributes.serialized)
            }
        }
        
        return newJSON
    }
}