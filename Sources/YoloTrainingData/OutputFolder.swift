//
//  OutputFolder.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation

struct OutputFolder {
    
    let outputURL: URL
    
    let trainImagesUrl: URL
    let validateImagesUrl: URL
    
    let trainLabelsUrl: URL
    let validateLabelsUrl: URL
    
    init(outputURL: URL) {
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
}

