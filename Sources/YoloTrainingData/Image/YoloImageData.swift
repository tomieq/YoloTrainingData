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
    
    init(classID: Int, centerX: Double, centerY: Double, width: Double, height: Double) {
        self.classID = classID
        self.centerX = centerX
        self.centerY = centerY
        self.width = width
        self.height = height
    }
    
    init? (serialized: String) {
        let parts = serialized.split(" ")
        guard parts.count == 5 else { return nil }

        self.classID = Int(parts[0])!
        self.centerX = Double(parts[1])!
        self.centerY = Double(parts[2])!
        self.width = Double(parts[3])!
        self.height = Double(parts[4])!
    }
}

extension YoloImageData {
    var serialized: String {
        "\(classID) \(centerX) \(centerY) \(width) \(height)"
    }
}
