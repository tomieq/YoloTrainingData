//
//  ImageInfo.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//

class ImageInfo {
    var type: ImageType
    var objects: [ObjectOnImage]
    
    init(type: ImageType = .training, objects: [ObjectOnImage] = []) {
        self.type = type
        self.objects = objects
    }
}

