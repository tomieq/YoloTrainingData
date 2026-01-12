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
    // key is index of image
    private var imageData: [ImageData] = []
    private let outputWriter: OutputWriter
    
    var inputImages: [ImageData] {
        imageData
    }
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
        
        let folder = OutputFolder(inputURL: inputURL, outputURL: outputURL)
        self.imageData = try InputImageLoader(folder: folder).load()
        logger.i("Loaded \(imageData.count) images")
        self.outputWriter = OutputWriter(folder: folder)
    }
    
    func addLabel(name: String) {
        let label = Label(id: labels.count, name: name)
        labels.append(label)
        logger.i("Added label \(label)")
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
        data.status = status
    }
    
    func getImageStatus(imageIndex: Int) -> ImageStatus? {
        imageData[safeIndex: imageIndex]?.status
    }
    
    func removeObject(imageIndex: Int, objectIndex: Int) {
        guard let image = imageData[safeIndex: imageIndex] else {
            return
        }
        image.objects.remove(at: objectIndex)
        if image.objects.isEmpty {
            image.status = .unused
        }
        outputWriter.store(data: image, withStatus: image.status)
    }
    
    func getObjectsOnImage(imageIndex: Int) -> [ObjectOnImage] {
        imageData[safeIndex: imageIndex]?.objects ?? []
    }
}
