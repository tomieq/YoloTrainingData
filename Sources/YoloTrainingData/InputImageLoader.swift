//
//  InputImageLoader.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation
import Logger

class InputImageLoader {
    private let logger = Logger(InputImageLoader.self)
    let inputURL: URL
    let outputFolder: OutputFolder
    
    init(inputURL: URL, outputURL: URL) {
        self.inputURL = inputURL
        self.outputFolder = .init(outputURL: outputURL)
    }
    
    func load() throws -> [ImageData] {
        try load(url: inputURL, subdirectory: "")
    }
    
    private func load(url: URL, subdirectory: String) throws -> [ImageData] {
        var images: [ImageData] = []
        
        // images from input folder
        for url in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) {
            if url.path.hasSuffix(".jpg").or(url.path.hasSuffix(".png")) {
                
                let imageData = ImageData(inputImage: InputImage(url: url, filename: subdirectory + url.lastPathComponent))
                let labelFilename = imageData.outputFileName.split(".")[0] + ".txt"
                
                let validationLabelsUrl = outputFolder.validateLabelsUrl.appendingPathComponent(labelFilename)
                if FileManager.default.fileExists(atPath: validationLabelsUrl.path) {
                    loadObjects(to: imageData, from: validationLabelsUrl)
                    imageData.type = .validation
                }
                
                let trainingLabelsUrl = outputFolder.trainLabelsUrl.appendingPathComponent(labelFilename)
                if FileManager.default.fileExists(atPath: trainingLabelsUrl.path) {
                    loadObjects(to: imageData, from: trainingLabelsUrl)
                    imageData.type = .training
                }
                
                images.append(imageData)
                
            } else if let isDir = try? isDirectory(url: url), isDir {
                var lowerSubdirectory = subdirectory
                lowerSubdirectory.append("\(url.lastPathComponent)/")
                images.append(contentsOf: try load(url: url, subdirectory: lowerSubdirectory))
            }
        }
        return images.sorted(by: { $0.inputImage.url.path < $1.inputImage.url.path })
    }
    
    private func isDirectory(url: URL) throws -> Bool {
        try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false
    }
    
    func loadObjects(to imageData: ImageData, from url: URL) {
        logger.d("Loading objects for \(url.path)")
        if let yoloDataLines = try? String(contentsOf: url, encoding: .utf8).split("\n") {
            let yoloData = yoloDataLines.map { YoloImageData(serialized: $0) }
            let objects = yoloData.map { yoloData in
                
                let areaWidth = Int(Double(imageData.size.width) * yoloData.width)
                let areaHeight = Int(Double(imageData.size.height) * yoloData.height)
                
                return ObjectOnImage(labelID: yoloData.classID,
                                     imageArea: ImageArea(left: Int(Double(imageData.size.width) * yoloData.centerX) - areaWidth / 2,
                                                          top: Int(Double(imageData.size.height) * yoloData.centerY) - areaHeight / 2,
                                                          width: areaWidth,
                                                          height: areaHeight))
            }
            logger.i("Loaded \(objects.count) objects from \(url.path)")
            imageData.objects = objects
        }
    }
}

