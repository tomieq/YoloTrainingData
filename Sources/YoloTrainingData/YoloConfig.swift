//
//  YoloConfig.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 12/01/2026
//

class YoloConfig: Codable {
    let train: String
    let val: String
    let nc: Int
    let names: [String]
    
    init(train: String, val: String, names: [String]) {
        self.train = train
        self.val = val
        self.nc = names.count
        self.names = names
    }
}

