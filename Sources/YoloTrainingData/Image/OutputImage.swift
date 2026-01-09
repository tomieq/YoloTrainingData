//
//  OutputImage.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import SwiftExtensions

class OutputImage {
    let inputImage: InputImage
    
    init(inputImage: InputImage) {
        self.inputImage = inputImage
    }
    
    var fileName: String {
        inputImage.subdirectory.replacingOccurrences(of: "/", with: "-").appending(inputImage.filename)
    }
}

