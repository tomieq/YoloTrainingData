//
//  InputImage.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation

struct InputImage {
    let url: URL
    let subdirectory: String
    let filename: String
    
    init(url: URL, subdirectory: String) {
        self.url = url
        self.subdirectory = subdirectory
        self.filename = url.lastPathComponent
    }
}

