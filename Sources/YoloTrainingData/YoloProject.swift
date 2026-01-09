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
    private var labels: [Label]
    private let inputImages: [InputImage]
    private let outputWriter: OutputWriter
    var objectLabels: [Label] {
        labels
    }
    
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
        
        self.inputImages = try InputImageLoader(inputURL: inputURL).load()
        logger.i("Loaded \(inputImages.count) images")
        logger.i("Images: \(inputImages)")
        self.outputWriter = OutputWriter(outputURL: outputURL)
    }
    
    func addLabel(name: String) {
        let label = Label(id: labels.count, name: name)
        labels.append(label)
        logger.i("Added label \(label)")
    }
}
