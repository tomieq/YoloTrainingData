//
//  ImageData.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation
import SwiftGD
import SwiftExtensions

class ImageData {
    let filename: String
    var url: URL
    var status: ImageStatus
    var objects: [ObjectOnImage]
    
    init(filename: String, url: URL, status: ImageStatus = .unused, objects: [ObjectOnImage] = []) {
        self.filename = filename
        self.url = url
        self.status = status
        self.objects = objects
    }
    
    lazy var size: ImageSize = {
        guard let image = Image(url: url) else {
            fatalError("Cant read size of image at \(url.path)")
            return ImageSize(width: 0, height: 0)
        }
        return ImageSize(width: image.size.width, height: image.size.height)
    }()
}

extension ImageData {
    var yoloImageData: [YoloImageData] {
        objects.map { object in
            YoloImageData(classID: object.labelID,
                          centerX: (Double(object.imageArea.left) + Double(object.imageArea.width) / 2.0) / Double(size.width),
                          centerY: (Double(object.imageArea.top) + Double(object.imageArea.height) / 2.0) / Double(size.height),
                          width: Double(object.imageArea.width) / Double(size.width),
                          height: Double(object.imageArea.height) / Double(size.height))
        }
    }

}
