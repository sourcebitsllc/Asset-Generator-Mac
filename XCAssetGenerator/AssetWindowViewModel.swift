//
//  AssetWindowViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa


class AssetWindowViewModel {
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
        
        let notCurrentlyGenerating: () -> Bool = {
            return self.progressViewModel.animating.value == false
        }
        
        let inputsSignal = combineLatest(imagesViewModel.selectionSignal, projectViewModel.selectionSignal)
        let inputsContentSignal = combineLatest(imagesViewModel.contentSignal, projectViewModel.contentSignal)

        statusLabel <~ inputsSignal
            |> map { assets, project in
                return StatusCrafter.status(assets: assets, target: project)
        }
        
        statusLabel <~ inputsContentSignal
            |> filter { _ in notCurrentlyGenerating() }
            |> map { _ in
                let assets = self.imagesViewModel.assetRepresentation()
                let catalog = self.projectViewModel.currentCatalog
                return StatusCrafter.status(assets: assets, target: catalog)
        }
    
        // RAC3 TODO:
        canGenerate <~ combineLatest(inputsSignal, assetGenerator.running.producer)
//            |> throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
            |> map { input, running in
                        let validSource = AssetGeneratorInputValidator.validateSource(input.0)
                        let validTarget = AssetGeneratorInputValidator.validateTarget(input.1)
                        let notRunning  = running == false
                        return validSource && validTarget && notRunning
            }
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
                        StatusCrafter.postGeneration(catalog!.title, amount: a) |> self.statusLabel.put
                    }
            })
            |> start()
    }
    
}
