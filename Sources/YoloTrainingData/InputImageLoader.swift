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
    let folder: OutputFolder
    
    init(folder: OutputFolder) {
        self.folder = folder
    }
    
    func load() throws -> [ImageData] {
        (try load(url: folder.inputURL, subdirectory: "", status: .unused) +
        load(url: folder.trainImagesUrl, subdirectory: "", status: .forTraining) +
        load(url: folder.validateImagesUrl, subdirectory: "", status: .forValidation)
        ).sorted { $0.filename < $1.filename }
    }
    
    private func load(url: URL, subdirectory: String, status: ImageStatus) throws -> [ImageData] {
        var images: [ImageData] = []
        
        logger.i("Loading images from \(url.path)")
        // images from input folder
        for url in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) {
            if url.path.hasSuffix(".jpg").or(url.path.hasSuffix(".png")) {
                
                let imageData = ImageData(filename: subdirectory + url.lastPathComponent, url: url, status: status)
                if status != .unused, let labelUrl = folder.currentLabelUrl(image: imageData) {
                    if FileManager.default.fileExists(atPath: labelUrl.path) {
                        loadObjects(to: imageData, from: labelUrl)
                    }
                }
                images.append(imageData)
                
            } else if let isDir = try? isDirectory(url: url), isDir {
                var lowerSubdirectory = subdirectory
                lowerSubdirectory.append("\(url.lastPathComponent)/")
                images.append(contentsOf: try load(url: url, subdirectory: lowerSubdirectory, status: status))
            }
        }
        return images.sorted(by: { $0.filename < $1.filename })
    }
    
    private func isDirectory(url: URL) throws -> Bool {
        try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false
    }
    
    func loadObjects(to imageData: ImageData, from url: URL) {
        if let yoloDataLines = try? String(contentsOf: url, encoding: .utf8).split("\n") {
            let yoloData = yoloDataLines.compactMap { YoloImageData(serialized: $0) }
            let objects = yoloData.map { yoloData in
                let areaWidth = Int(Double(imageData.size.width) * yoloData.width)
                let areaHeight = Int(Double(imageData.size.height) * yoloData.height)
                
                return ObjectOnImage(labelID: yoloData.classID,
                                     imageArea: ImageArea(left: Int(Double(imageData.size.width) * yoloData.centerX) - areaWidth / 2,
                                                          top: Int(Double(imageData.size.height) * yoloData.centerY) - areaHeight / 2,
                                                          width: areaWidth,
                                                          height: areaHeight))
            }
            imageData.objects = objects
        }
    }
}

