//
//  WebServer.swift
//  YoloTrainingData
// 
//  Created by: tomieq on 09/01/2026
//
import Swifter
import Foundation
import SwiftExtensions
import Env
import Logger
import Template
import BootstrapTemplate

class WebServer {
    private let logger = Logger(WebServer.self)
    private let server = HttpServer()
    private let project: YoloProject
    
    init(project: YoloProject, env: Env) {
        self.project = project
        setupEndpoints()
        try? server.start(env.int("PORT")?.uInt16 ?? 8080, forceIPv4: true)
        logger.i("Started web server on port \(try! server.port)")
    }

    var pageTemplate: Template {
        Template.cached(relativePath: "templates/index.html")
    }
    
    func wrapTemplate(_ content: CustomStringConvertible) -> BootstrapTemplate {
        let main = BootstrapTemplate()
        main.body = content
        main.addCSS(url: "style.css")
        return main
    }

    private func setupEndpoints() {
        server["/"] = { [unowned self] request, _ in

            if let newLabelName = request.formData["label"], newLabelName.isEmpty.not {
                project.addLabel(name: newLabelName)
            }
            let listTemplate = Template.cached(relativePath: "templates/label-list.tpl.html")
            for label in project.objectLabels {
                listTemplate.assign(label, inNest: "label")
            }
            let form = Form(url: "/", method: "POST")
            form.addInputText(name: "label", label: "Label")
            form.addSubmit(name: "addLabel", label: "Add label", style: .info)
            listTemplate["form"] = form
            let template = self.pageTemplate
            template["content"] = listTemplate
            return .ok(.html(wrapTemplate(template)))
        }
        
        server.notFoundHandler = { request, responseHeaders in
            request.disableKeepAlive = true
            if let filePath = BootstrapTemplate.absolutePath(for: request.path) {
                try HttpFileResponse.with(absolutePath: filePath)
            }
            let filePath = Resource().absolutePath(for: request.path)
            try HttpFileResponse.with(absolutePath: filePath)
            print("File `\(filePath)` doesn't exist")
            return .notFound()
        }
        
        server.middleware.append { [unowned self] request, header in
            logger.i("Request \(request.id) \(request.method) \(request.path) from \(request.clientIP ?? "")")
            request.onFinished { [unowned self] summary in
                // finish tracking
                // id is unique UUID for this request
                // responseCode is the http code that was returned to client
                // responseSize is expressed in DataSize
                // durationInSeconds is the time in seconds
                self.logger.i("Request \(summary.requestID) finished with \(summary.responseCode) [\(summary.responseSize)] in \(String(format: "%.3f", summary.durationInSeconds)) seconds")
            }
            return nil
        }
    }
}
