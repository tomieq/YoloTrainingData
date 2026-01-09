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
    let inputImages: [InputImage]
    // key is index of image
    private var imageInfo: [Int: ImageInfo] = [:]
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
        self.outputWriter = OutputWriter(outputURL: outputURL)
    }
    
    func addLabel(name: String) {
        let label = Label(id: labels.count, name: name)
        labels.append(label)
        logger.i("Added label \(label)")
    }
    
    func addObject(imageIndex: Int, labelID: Int, imageArea: ImageArea) {
        guard let inputImage = inputImages[safeIndex: imageIndex] else {
            logger.e("No image at index \(imageIndex)")
            return
        }
        logger.i("Added label \(labelID) on image \(imageIndex)")
        let data = imageInfo[imageIndex] ?? ImageInfo()
        data.objects.append(ObjectOnImage(labelID: labelID, imageArea: imageArea))
        imageInfo[imageIndex] = data
        outputWriter.store(inputImage: inputImage, objects: data.objects, type: data.type)
    }
    
    func removeObject(imageIndex: Int, objectIndex: Int) {
        imageInfo[imageIndex]?.objects.remove(at: objectIndex)
    }
    
    func getObjectsOnImage(imageIndex: Int) -> [ObjectOnImage] {
        imageInfo[imageIndex]?.objects ?? []
    }
}
