//
//  YoloProject.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation
import Logger

enum YoloProjectError: Error {
    case invalidInputURL
    case invalidOutputURL
}

class YoloProject {
    private let logger = Logger(YoloProject.self)
    let inputURL: URL
    let outputURL: URL
    var labels: [Label]
    let inputImages: [InputImage]
    
    init(inputURL: URL, outputURL: URL) throws {
        
        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            throw YoloProjectError.invalidInputURL
        }
        guard FileManager.default.fileExists(atPath: outputURL.path) else {
            throw YoloProjectError.invalidOutputURL
        }
        self.inputURL = inputURL
        self.outputURL = outputURL
        self.labels = []
        
        var inputImages: [InputImage] = []
        for url in try FileManager.default.contentsOfDirectory(at: inputURL, includingPropertiesForKeys: nil, options: []) {
            inputImages.append(InputImage(url: url))
        }
        self.inputImages = inputImages
        logger.i("Loaded \(inputImages.count) images")
    }
}
