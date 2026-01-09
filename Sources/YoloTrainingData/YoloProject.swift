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
    
    var inputImages: [InputImage] {
        imageData.map(\.inputImage)
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
        
        self.imageData = try InputImageLoader(inputURL: inputURL, outputURL: outputURL).load()
        logger.i("Loaded \(imageData.count) images")
        self.outputWriter = OutputWriter(outputURL: outputURL)
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
        outputWriter.store(data: data)
    }
    
    func setImageType(imageIndex: Int, type: ImageType) {
        guard let data = imageData[safeIndex: imageIndex] else {
            logger.e("Invalid image index \(imageIndex)")
            return
        }
        data.type = type
        outputWriter.store(data: data)
    }
    
    func setImageSize(imageIndex: Int, size: ImageSize) {
        guard let data = imageData[safeIndex: imageIndex] else {
            logger.e("Invalid image index \(imageIndex)")
            return
        }
        data.size = size
    }
    
    func getImageType(imageIndex: Int) -> ImageType? {
        imageData[safeIndex: imageIndex]?.type
    }
    
    func removeObject(imageIndex: Int, objectIndex: Int) {
        imageData[safeIndex: imageIndex]?.objects.remove(at: objectIndex)
    }
    
    func getObjectsOnImage(imageIndex: Int) -> [ObjectOnImage] {
        imageData[safeIndex: imageIndex]?.objects ?? []
    }
}
