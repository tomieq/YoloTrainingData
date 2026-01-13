//
//  YoloProject.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation
import Logger
import Yams

enum YoloProjectError: Error {
    case invalidInputURL
    case invalidOutputURL
}

class YoloProject {
    private let logger = Logger(YoloProject.self)
    private var labels: [Label]
    // key is index of image
    private var imageData: [ImageData] = []
    private let outputWriter: OutputWriter
    private let folder: OutputFolder
    
    var inputImages: [ImageData] {
        imageData
    }
    var objectLabels: [Label] {
        labels
    }
    
    init(inputURL: URL, yoloConfigUrl: URL) throws {
        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            throw YoloProjectError.invalidInputURL
        }
        let outputURL = yoloConfigUrl.deletingLastPathComponent()
        guard FileManager.default.fileExists(atPath: outputURL.path) else {
            throw YoloProjectError.invalidOutputURL
        }
        self.labels = []
        
        self.folder = OutputFolder(inputURL: inputURL, yoloConfigUrl: yoloConfigUrl)
        self.imageData = try InputImageLoader(folder: folder).load()
        logger.i("Loaded \(imageData.count) images")
        
        if let yamlString = try? String(contentsOf: yoloConfigUrl), let config = try? YAMLDecoder().decode(YoloConfig.self, from: yamlString) {
            print("Loaded config: \(config)")
            print("train path: \(config.train)")
            for (index, name) in config.names.enumerated() {
                labels.append(Label(id: index, name: name))
            }
        }
        self.outputWriter = OutputWriter(folder: folder)
    }
    
    func addLabel(name: String) {
        let label = Label(id: labels.count, name: name)
        labels.append(label)
        logger.i("Added label \(label)")
        
        let config = YoloConfig(train: "images/train", val: "images/val", names: labels.map(\.name))
        let encoder = YAMLEncoder()
        if let data = try? encoder.encode(config) {
            try? data.write(to: folder.yoloConfigUrl, atomically: true, encoding: .utf8)
        }
    }
    
    func addObject(imageIndex: Int, labelID: Int, imageArea: ImageArea) {
        guard let data = imageData[safeIndex: imageIndex] else {
            logger.e("No image at index \(imageIndex)")
            return
        }
        logger.i("Added label \(labelID) on image \(imageIndex)")
        data.objects.append(ObjectOnImage(labelID: labelID, imageArea: imageArea))
        let newStatus = data.status == .unused ? .forTraining : data.status
        outputWriter.store(data: data, withStatus: newStatus)
    }
    
    func setImageStatus(imageIndex: Int, status: ImageStatus) {
        guard let data = imageData[safeIndex: imageIndex] else {
            logger.e("Invalid image index \(imageIndex)")
            return
        }
        outputWriter.store(data: data, withStatus: status)
    }
    
    func getImageStatus(imageIndex: Int) -> ImageStatus? {
        imageData[safeIndex: imageIndex]?.status
    }
    
    func removeObject(imageIndex: Int, objectIndex: Int) {
        guard let image = imageData[safeIndex: imageIndex] else {
            return
        }
        logger.i("Removed label \(objectIndex) on image \(imageIndex)")
        image.objects.remove(at: objectIndex)
        var newStatus = image.status
        if image.objects.isEmpty {
            newStatus = .unused
        }
        outputWriter.store(data: image, withStatus: newStatus)
    }
    
    func getObjectsOnImage(imageIndex: Int) -> [ObjectOnImage] {
        imageData[safeIndex: imageIndex]?.objects ?? []
    }
}
