//
//  OutputWriter.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation
import SwiftExtensions

class OutputWriter {
    let outputFolder: OutputFolder
    
    init(outputURL: URL) {
        self.outputFolder = OutputFolder(outputURL: outputURL)
        try? FileManager.default.createDirectory(at: outputFolder.trainImagesUrl, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: outputFolder.validateImagesUrl, withIntermediateDirectories: true)
        
        try? FileManager.default.createDirectory(at: outputFolder.trainLabelsUrl, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: outputFolder.validateLabelsUrl, withIntermediateDirectories: true)
    }
    
    func store(data: ImageData) {
        let imageUrl: URL
        let labelsUrl: URL
        
        
        let imageFilename = data.outputFileName
        let labelFilename = "\(imageFilename.split(".")[0]).txt"
        
        if data.status == .forTraining {
            imageUrl = outputFolder.trainImagesUrl.appendingPathComponent(imageFilename)
            labelsUrl = outputFolder.trainLabelsUrl.appendingPathComponent(labelFilename)
            
            try? FileManager.default.removeItem(at: outputFolder.validateImagesUrl.appendingPathComponent(imageFilename))
        } else {
            imageUrl = outputFolder.validateImagesUrl.appendingPathComponent(imageFilename)
            labelsUrl = outputFolder.validateLabelsUrl.appendingPathComponent(labelFilename)
            
            try? FileManager.default.removeItem(at: outputFolder.trainImagesUrl.appendingPathComponent(imageFilename))
        }
        if FileManager.default.fileExists(atPath: imageUrl.path).not {
            try? FileManager.default.copyItem(at: data.inputImage.url, to: imageUrl)
        }
        
        try? FileManager.default.removeItem(at: outputFolder.trainLabelsUrl.appendingPathComponent(labelFilename))
        try? FileManager.default.removeItem(at: outputFolder.validateLabelsUrl.appendingPathComponent(labelFilename))
        
        try? data.yoloImageData.map { $0.serialized }.joined(separator: "\n").write(to: labelsUrl, atomically: false , encoding: .utf8)
        
    }
}

