//
//  main.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Foundation
import Env
import SwiftExtensions



enum ConfirError: Error {
    case noInputUrl
    case noYoloUrl
}

let env = Env("local.env")

let inputUrl = try env.get("INPUT_URL") ?! ConfirError.noInputUrl
let yoloConfigUrl = try env.get("YOLO_YML_URL") ?! ConfirError.noYoloUrl

print("Started with \(yoloConfigUrl)")

let project = try YoloProject(inputURL: URL(fileURLWithPath: inputUrl, isDirectory: true),
                              yoloConfigUrl: URL(fileURLWithPath: yoloConfigUrl, isDirectory: true))

let webServer = WebServer(project: project, env: env)
RunLoop.main.run()
