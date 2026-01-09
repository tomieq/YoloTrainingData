//
//  InputImageLoader.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation

class InputImageLoader {
    let inputURL: URL
    
    init(inputURL: URL) {
        self.inputURL = inputURL
    }
    
    func load() throws -> [InputImage] {
        try load(url: inputURL, subdirectory: "")
    }
    
    private func load(url: URL, subdirectory: String) throws -> [InputImage] {
        var images: [InputImage] = []
        for url in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) {
            if url.path.hasSuffix(".jpg").or(url.path.hasSuffix(".png")) {
                images.append(InputImage(url: url, subdirectory: subdirectory))
            } else if let isDir = try? isDirectory(url: url), isDir {
                var lowerSubdirectory = subdirectory
                lowerSubdirectory.append("\(url.lastPathComponent)/")
                images.append(contentsOf: try load(url: url, subdirectory: lowerSubdirectory))
            }
            
        }
        return images.sorted(by: { $0.url.path < $1.url.path })
    }
    
    private func isDirectory(url: URL) throws -> Bool {
        try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false
    }
}

