//
//  OutputFolder.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation

struct OutputFolder {
    
    let inputURL: URL
    let outputURL: URL
    
    let trainImagesUrl: URL
    let validateImagesUrl: URL
    
    let trainLabelsUrl: URL
    let validateLabelsUrl: URL
    
    init(inputURL: URL, outputURL: URL) {
        self.inputURL = inputURL
        self.outputURL = outputURL
        
        let imagesUrl = outputURL.appendingPathComponent("images")
        trainImagesUrl = imagesUrl.appendingPathComponent("train")
        validateImagesUrl = imagesUrl.appendingPathComponent("val")
        try? FileManager.default.createDirectory(at: trainImagesUrl, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: validateImagesUrl, withIntermediateDirectories: true)
        
        let labelsUrl = outputURL.appendingPathComponent("labels")
        trainLabelsUrl = labelsUrl.appendingPathComponent("train")
        validateLabelsUrl = labelsUrl.appendingPathComponent("val")
        try? FileManager.default.createDirectory(at: trainLabelsUrl, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: validateLabelsUrl, withIntermediateDirectories: true)
    }
    
    func currentImageUrl(image: ImageData) -> URL {
        imageUrl(image: image, for: image.status)
    }
    
    func imageUrl(image: ImageData, for status: ImageStatus) -> URL {
        switch status {
        case .unused:
            inputURL.appendingPathComponent(image.filename)
        case .forTraining:
            trainImagesUrl.appendingPathComponent(image.filename.replacingOccurrences(of: "/", with: "-"))
        case .forValidation:
            validateImagesUrl.appendingPathComponent(image.filename.replacingOccurrences(of: "/", with: "-"))
        }
    }
    
    func currentLabelUrl(image: ImageData) -> URL? {
        labelUrl(image: image, for: image.status)
    }
    
    func labelUrl(image: ImageData, for status: ImageStatus) -> URL? {
        switch status {
        case .unused:
            nil
        case .forTraining:
            trainLabelsUrl.appendingPathComponent(image.filename.replacingOccurrences(of: "/", with: "-").split(".")[0] + ".txt")
        case .forValidation:
            validateLabelsUrl.appendingPathComponent(image.filename.replacingOccurrences(of: "/", with: "-").split(".")[0] + ".txt")
        }
    }
}

