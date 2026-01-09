//
//  OutputWriter.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation
import SwiftExtensions

class OutputWriter {
    let outputURL: URL
    private let trainImagesUrl: URL
    private let validateImagesUrl: URL
    private let trainLabelsUrl: URL
    private let validateLabelsUrl: URL
    
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
    
    func store(data: ImageData) {
        let imageUrl: URL
        let labelsUrl: URL
        
        
        let imageFilename = data.inputImage.filename.replacingOccurrences(of: "/", with: "-")
        let labelFilename = "\(imageFilename.split(".")[0]).txt"
        
        if data.type == .training {
            imageUrl = trainImagesUrl.appendingPathComponent(imageFilename)
            labelsUrl = trainLabelsUrl.appendingPathComponent(labelFilename)
            
            try? FileManager.default.removeItem(at: validateImagesUrl.appendingPathComponent(imageFilename))
        } else {
            imageUrl = validateImagesUrl.appendingPathComponent(imageFilename)
            labelsUrl = validateLabelsUrl.appendingPathComponent(labelFilename)
            
            try? FileManager.default.removeItem(at: trainImagesUrl.appendingPathComponent(imageFilename))
        }
        if FileManager.default.fileExists(atPath: imageUrl.path).not {
            try? FileManager.default.copyItem(at: data.inputImage.url, to: imageUrl)
        }
        
        try? FileManager.default.removeItem(at: trainLabelsUrl.appendingPathComponent(labelFilename))
        try? FileManager.default.removeItem(at: validateLabelsUrl.appendingPathComponent(labelFilename))
        
        try? data.yoloImageData.map { $0.serialized }.joined(separator: "\n").write(to: labelsUrl, atomically: false , encoding: .utf8)
        
    }
}

