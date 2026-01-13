//
//  OutputFolder.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation
import SwiftExtensions
import Yams
import Logger

struct OutputFolder {
    
    private let logger = Logger(OutputFolder.self)
    let inputURL: URL
    let outputURL: URL
    let yoloConfigUrl: URL
    
    let trainImagesUrl: URL
    let validateImagesUrl: URL
    
    let trainLabelsUrl: URL
    let validateLabelsUrl: URL
    
    init(inputURL: URL, yoloConfigUrl: URL) {
        self.inputURL = inputURL
        self.outputURL = yoloConfigUrl.deletingLastPathComponent()
        self.yoloConfigUrl = yoloConfigUrl
        
        var trainPath = "images/train"
        var valPath = "images/val"
        
        if let yamlString = try? String(contentsOf: yoloConfigUrl),
            let config = try? YAMLDecoder().decode(YoloConfig.self, from: yamlString) {
            trainPath = config.train
            valPath = config.val
        }
        trainImagesUrl = Self.appending(relativePath: trainPath, to: outputURL)
        validateImagesUrl = Self.appending(relativePath: valPath, to: outputURL)
        
        try? FileManager.default.createDirectory(at: trainImagesUrl, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: validateImagesUrl, withIntermediateDirectories: true)
        
        trainLabelsUrl = Self.appending(relativePath: trainPath.replacingOccurrences(of: "images", with: "/labels"), to: outputURL)
        validateLabelsUrl = Self.appending(relativePath: valPath.replacingOccurrences(of: "images", with: "/labels"), to: outputURL)
        
        logger.i("train images url: \(trainImagesUrl)")
        logger.i("train labels url: \(trainLabelsUrl)")
        
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
            labelUrl(base: trainLabelsUrl, imageFilename: image.filename)
        case .forValidation:
            labelUrl(base: validateLabelsUrl, imageFilename: image.filename)
        }
    }
    
    private static func appending(relativePath: String, to baseURL: URL) -> URL {
        var url = baseURL

        for component in relativePath.split(separator: "/") {
            if component == ".." {
                url.deleteLastPathComponent()
            } else if component != "." {
                url.appendPathComponent(String(component))
            }
        }

        return url
    }
    
    private func labelUrl(base: URL, imageFilename: String) -> URL {
        var parts = imageFilename.replacingOccurrences(of: "/", with: "-").split(".")
        parts.removeLast()
        parts.append("txt")
        var base = base
        base.appendPathComponent(parts.joined(separator: "."))
        return base
    }
}

