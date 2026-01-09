//
//  YoloImageData.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//

import Foundation

struct YoloImageData {
    let classID: Int
    let centerX: Double
    let centerY: Double
    let width: Double
    let height: Double
}

extension YoloImageData {
    var serialized: String {
        "\(classID) \(centerX) \(centerY) \(width) \(height)"
    }
}
