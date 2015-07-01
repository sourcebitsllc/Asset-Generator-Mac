//
//  AssetWindowViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa


struct AssetWindowViewModel {
    let statusLabel: MutableProperty<String>
    let canGenerate = MutableProperty<Bool>(false)
    let generateTitle = MutableProperty<String>("Build")
    
    private let imagesViewModel: ImagesGroupViewModel
    private let projectViewModel: ProjectSelectionViewModel
    private var progressViewModel: ProgressIndicationViewModel
    private let assetGenerator: AssetGenerationController
    
    // RAC3 TODO: Main WindowController Initialization.
    init() {
        imagesViewModel = ImagesGroupViewModel()
        projectViewModel = ProjectSelectionViewModel()
        progressViewModel = ProgressIndicationViewModel()
        assetGenerator  = AssetGenerationController()
      
        statusLabel = MutableProperty<String>("")
        
        statusLabel <~ combineLatest(imagesViewModel.selectionSignal, projectViewModel.selectionSignal)
            |> map { assets, project in
                return StatusCrafter.status(assets: assets, target: project)
        }
        
        statusLabel <~ combineLatest(imagesViewModel.contentSignal, projectViewModel.contentSignal)
            |> filter { _ in
                let stable = self.progressViewModel.animating.value == false
                return stable }
            |> map { _ in
                let assets = self.imagesViewModel.assetRepresentation()
                let catalog = self.projectViewModel.currentCatalog
                return StatusCrafter.status(assets: assets, target: catalog)
        }
    
        
//        statusLabel <~ assetGenerator.generatedSignal |> map { generated in
//            let catalog = self.projectViewModel.currentCatalog!
//            return StatusCrafter.postGeneration(catalog, amount: generated)
//        }
        
        //
        // RAC3 TODO:
        canGenerate <~ combineLatest(imagesViewModel.selectionSignal, projectViewModel.selectionSignal, assetGenerator.running.producer)
//            |> throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
            |> map { assets, project, running in
                        let validSource = AssetGeneratorInputValidator.validateSource(assets)
                        let validTarget = AssetGeneratorInputValidator.validateTarget(project)
                        let notRunning  = running == false
                        return validSource && validTarget && notRunning
            }
//        generateTitle <~ assetGenerator.generatedSignal
////            |> throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
//            |> map { _ in return "Build Again" }
        
    }
    
    func viewModelForImagesGroup() -> ImagesGroupViewModel {
        return imagesViewModel
    }
    
    func viewModelForSelectedProject() -> ProjectSelectionViewModel {
        return projectViewModel
    }
    
    func viewModelForProgressIndication() -> ProgressIndicationViewModel {
        return progressViewModel
    }
    
    func generateAssets() {
        // Wut
        let assets = imagesViewModel.assetRepresentation()
        let catalog = projectViewModel.currentCatalog
        // End Wut
        assetGenerator.assetGenerationProducer(assets, destination: catalog?.path)
            |> startOn(QueueScheduler.mainQueueScheduler)
            |> on(started: {
                self.progressViewModel.progressStarted()
                }, completed: {
                    self.generateTitle.put("Build Again")
                    self.progressViewModel.progressFinished()
                }, next: { report in
                    switch report {
                    case .Progress(let p):
                        self.progressViewModel.updateProgress(p)
                    case .Assets(let a):
//                        let catalog = self.projectViewModel.currentCatalog!
                        StatusCrafter.postGeneration(catalog!.title, amount: a) |> self.statusLabel.put
                    }
            })
            |> start()
    }
    
}
