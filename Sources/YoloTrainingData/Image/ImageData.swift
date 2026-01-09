//
//  ImageData.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//

class ImageData {
    let inputImage: InputImage
    var type: ImageType
    var objects: [ObjectOnImage]
    var size: ImageSize?
    
    init(inputImage: InputImage, type: ImageType = .training, objects: [ObjectOnImage] = []) {
        self.inputImage = inputImage
        self.type = type
        self.objects = objects
        self.size = nil
    }
}

