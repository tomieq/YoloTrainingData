//
//  main.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation
import Env
import SwiftExtensions

print("Started")

enum ConfirError: Error {
    case noInputUrl
    case noOutputUrl
}

let env = Env("local.env")

let inputUrl = try env.get("INPUT_URL") ?! ConfirError.noInputUrl
let outputUrl = try env.get("OUTPUT_URL") ?! ConfirError.noOutputUrl

let project = try YoloProject(inputURL: URL(fileURLWithPath: inputUrl, isDirectory: true),
                              outputURL: URL(fileURLWithPath: outputUrl, isDirectory: true))

