//
//  OutputWriter.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation
import SwiftExtensions

class OutputWriter {
    let folder: OutputFolder
    
    init(folder: OutputFolder) {
        self.folder = folder
        try? FileManager.default.createDirectory(at: folder.trainImagesUrl, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: folder.validateImagesUrl, withIntermediateDirectories: true)
        
        try? FileManager.default.createDirectory(at: folder.trainLabelsUrl, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: folder.validateLabelsUrl, withIntermediateDirectories: true)

    }
    
    func store(data: ImageData, withStatus status: ImageStatus) {
        // move file
        if data.status != status {
            try? FileManager.default.moveItem(at: folder.currentImageUrl(image: data), to: folder.imageUrl(image: data, for: status))
            if let labelCurrentUrl = folder.currentLabelUrl(image: data), let labelNewUrl = folder.labelUrl(image: data, for: status) {
                try? FileManager.default.moveItem(at: labelCurrentUrl, to: labelNewUrl)
            }
        }
        
        if let labelUrl = folder.labelUrl(image: data, for: status) {
            try? data.yoloImageData.map { $0.serialized }.joined(separator: "\n").write(to: labelUrl, atomically: false , encoding: .utf8)
        }

    }
}

