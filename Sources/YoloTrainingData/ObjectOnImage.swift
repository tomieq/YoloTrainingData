//
//  ObjectOnImage.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//

class ObjectOnImage {
    var labelID: Int
    let imageArea: ImageArea
    
    init(labelID: Int, imageArea: ImageArea) {
        self.labelID = labelID
        self.imageArea = imageArea
    }
}

