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
    private let env: Env
    
    init(project: YoloProject, env: Env) {
        self.project = project
        self.env = env
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
            return .ok(.html(wrapTemplate(self.pageTemplate)))
        }
        
        server["/labels"] = { [unowned self] request, _ in

            if let newLabelName = request.formData["label"], newLabelName.isEmpty.not {
                project.addLabel(name: newLabelName)
            }
            let listTemplate = Template.cached(relativePath: "templates/label-list.tpl.html")
            for label in project.objectLabels {
                listTemplate.assign(label, inNest: "label")
            }
            let form = Form(url: "/labels", method: "POST")
            form.addInputText(name: "label", label: "Label")
            form.addSubmit(name: "addLabel", label: "Add label", style: .secondary)
            listTemplate["form"] = form
            let template = self.pageTemplate
            template["content"] = listTemplate
            return .ok(.html(wrapTemplate(template)))
        }
        
        server["/images"] = { [unowned self] request, _ in

            let listTemplate = Template.cached(relativePath: "templates/image-list.tpl.html")
            for (index, image) in project.inputImages.enumerated() {
                let visibleName = image.subdirectory + image.filename
                listTemplate.assign(["imageIndex": "\(index)", "filename": visibleName], inNest: "image")
            }
            let template = self.pageTemplate
            template["content"] = listTemplate
            return .ok(.html(wrapTemplate(template)))
        }
        
        func selectLabelRaw() -> String {
            let selectLabelTemplate = Template.cached(relativePath: "templates/select-label.tpl.html")
            for label in project.objectLabels {
                selectLabelTemplate.assign(label, inNest: "option")
            }
            return selectLabelTemplate.output.replacingOccurrences(of: "\n", with: "")
        }
        
        server["/image"] = { [unowned self] request, _ in
            guard let index = request.queryParams.get("imageIndex")?.decimal, let inputImage = project.inputImages[safeIndex: index] else {
                return .movedTemporarily("/images")
            }
            struct Input: Codable {
                let frame: String
                let label: String
            }
            let input: Input = try request.formData.decode()
            if let frame = ImageArea(json: input.frame) {
                
            }
            
            
            let template = pageTemplate
            let picTemplate = Template.cached(relativePath: "templates/image-details.tpl.html")
            picTemplate["index"] = index
            picTemplate["nextIndex"] = index.incremented
            picTemplate["prevIndex"] = index.decremented
            picTemplate["imageUrl"] = "/file?imageIndex=\(index)"
            
            var counter = 0
            
            template["content"] = picTemplate
            let mainTemplate = wrapTemplate(template)
            mainTemplate.addJS(url: "/editor.js?imageIndex=" + index.description)
            mainTemplate.addJS(url: "/script.js")
            return .ok(.html(mainTemplate))
        }
        
        server["/file"] = { [unowned self] request, _ in
            guard let index = request.queryParams.get("imageIndex")?.decimal, let inputImage = project.inputImages[safeIndex: index] else {
                return .notFound()
            }
            try HttpFileResponse.with(absolutePath: inputImage.url.path)
            return .notFound()
        }
        
        server.get["editor.js"] = { request, _ in
            let js = Template.cached(relativePath: "templates/editor.tpl.js")
            js["imageIndex"] = request.queryParams.get("imageIndex")
            return .ok(.js(js))
        }
        
        server.get["/script.js"] = { [unowned self] request, _ in
            let js = Template.cached(relativePath: "templates/script.tpl.js")
            js["previewWidth"] = env.get("PREVIEW_WIDTH") ?? 512
            js["selectLabelRaw"] = selectLabelRaw()
            return .ok(.js(js))
        }
        
        server.get["/style.css"] = { [unowned self] request, _ in
            let css = Template.cached(relativePath: "templates/style.tpl.css")
            css["formLeftOffset"] = (env.get("PREVIEW_WIDTH")?.decimal ?? 512) + 5
            return .ok(.css(css))
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
