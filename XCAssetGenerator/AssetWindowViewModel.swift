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
    
    private let imagesViewModel: ImagesGroupViewModel!
    private let projectViewModel: SelectedProjectViewModel!
    private var progressViewModel: ProgressIndicationViewModel!
    
    /*private*/ let assetGenerator: AssetGenerationController!
    
    // RAC3 TODO: Main WindowController Initialization.
    init() {
        imagesViewModel = ImagesGroupViewModel()
        projectViewModel = SelectedProjectViewModel()
        progressViewModel = ProgressIndicationViewModel()
        assetGenerator  = AssetGenerationController()
        
        assetGenerator.source <~ imagesViewModel.pathSignal
        assetGenerator.target <~ projectViewModel.projectSignal |> map { project in return project?.assetPath }
        

        statusLabel = MutableProperty<String>("")
        statusLabel <~ combineLatest(imagesViewModel.pathSignal, projectViewModel.projectSignal, imagesViewModel.contentSignal, projectViewModel.contentSignal)
            |> filter { _,_,_,_ in
                let stable = self.progressViewModel.animating.value == false
                return stable
            }
            |> map { path, project, _, _ in
                return StatusViewModel.status(path, target: project)
        }

        statusLabel <~ assetGenerator.generatedSignal |> map { generated in
            let catalog = self.projectViewModel.currentCatalog!
            return StatusViewModel.postGeneration(catalog, amount: generated)
        }
        
        
        //
        // RAC3 TODO: this can be refactored to be prettier.
        canGenerate <~ combineLatest(imagesViewModel.pathSignal, projectViewModel.projectSignal, assetGenerator.running.producer)
//            |> throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
            |> map { path, project, running in
                        let validSource = AssetGeneratorInputValidator.validateSource(path)
                        let validTarget = AssetGeneratorInputValidator.validateTarget(project)
                        let notRunning  = running == false
                        println("Can Generate")
                        return validSource && validTarget && notRunning
            }
        generateTitle <~ assetGenerator.generatedSignal
//            |> throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
            |> map { _ in return "Build Again" }
    }
    
    func viewModelForImagesGroup() -> ImagesGroupViewModel {
        return imagesViewModel
    }
    
    func viewModelForSelectedProject() -> SelectedProjectViewModel {
        return projectViewModel
    }
    
    func viewModelForProgressIndication() -> ProgressIndicationViewModel {
        return progressViewModel
    }
    
    func generateAssets() {
        assetGenerator.assetGeneratorSignal
            |> startOn(QueueScheduler.mainQueueScheduler)
            |> on(completed: {
                self.progressViewModel.progressFinished()
                }, next: { r in
                    self.progressViewModel.updateProgress(r) })
            |> start()
    }
    
}
