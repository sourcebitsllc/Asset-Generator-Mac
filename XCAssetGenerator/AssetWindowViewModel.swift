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
    
    private let assetGenerator: AssetGenerationController!
    
    // RAC3 TODO: Main WindowController Initialization.
    init() {
        imagesViewModel = ImagesGroupViewModel()
        projectViewModel = ProjectSelectionViewModel()
        progressViewModel = ProgressIndicationViewModel()
        assetGenerator  = AssetGenerationController()
      
        statusLabel = MutableProperty<String>("")
        
        let c = combineLatest(imagesViewModel.selectionSignal, projectViewModel.projectSignal, imagesViewModel.contentSignal, projectViewModel.contentSignal) |> map { a in
            return ""
        }
        
        statusLabel <~ combineLatest(imagesViewModel.selectionSignal, projectViewModel.projectSignal, imagesViewModel.contentSignal, projectViewModel.contentSignal)
            |> filter { _,_,_,_ in
                let stable = self.progressViewModel.animating.value == false
                return stable
            }
            |> map { selection, project, _, _ in
                let assets = self.imagesViewModel.assetRepresentation()
                return StatusCrafter.status(assets: assets, target: project)
        }
        
        
//        statusLabel <~ assetGenerator.generatedSignal |> map { generated in
//            let catalog = self.projectViewModel.currentCatalog!
//            return StatusCrafter.postGeneration(catalog, amount: generated)
//        }
        
        //
        // RAC3 TODO: this can be refactored to be prettier.
        canGenerate <~ combineLatest(imagesViewModel.selectionSignal, projectViewModel.projectSignal, assetGenerator.running.producer)
//            |> throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
            |> map { selection, project, running in
                        let validSource = AssetGeneratorInputValidator.validateSource(self.imagesViewModel.assetRepresentation())
                        let validTarget = AssetGeneratorInputValidator.validateTarget(project)
                        let notRunning  = running == false
//                        println("Can Generate")
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
        let catalog: MutableProperty<Path?> = MutableProperty(nil)
        catalog <~ projectViewModel.projectSignal |> take(1) |> map { project in return project?.catalog?.path }
//        println(catalog.value)
        // End Wut
        assetGenerator.assetGenerationProducer(assets, destination: catalog.value)
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
                        let catalog = self.projectViewModel.currentCatalog!
                        StatusCrafter.postGeneration(catalog, amount: a) |> self.statusLabel.put
                    }
            })
            |> start()
    }
    
}
