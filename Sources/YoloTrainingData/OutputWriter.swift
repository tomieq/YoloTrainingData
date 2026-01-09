//
//  OutputWriter.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation

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
}

