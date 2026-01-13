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
import SwiftGD

class WebServer {
    private let logger = Logger(WebServer.self)
    private let server = HttpServer()
    private let project: YoloProject
    private let env: Env
    
    init(project: YoloProject, env: Env) {
        self.project = project
        self.env = env
        setupGeneralEndpoints()
        setupLabelEndpoints()
        setupImageEndpoints()
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

    
    private func setupGeneralEndpoints() {
        server["/"] = { [unowned self] request, _ in
            return .ok(.html(wrapTemplate(self.pageTemplate)))
        }
        
        server.get["/style.css"] = { [unowned self] request, _ in
            let css = Template.cached(relativePath: "templates/style.tpl.css")
            css["formLeftOffset"] = (env.get("PREVIEW_WIDTH")?.decimal ?? 512) + 5
            return .ok(.css(css))
        }
        
        server.notFoundHandler = { request, responseHeaders in
            request.disableKeepAlive = true
            if let filePath = BootstrapTemplate.absolutePath(for: request.path) {
                try HttpFileResponse.with(absolutePath: filePath, clientCache: .days(1))
            }
            let filePath = Resource().absolutePath(for: request.path)
            try HttpFileResponse.with(absolutePath: filePath, clientCache: .days(1))
            print("File `\(filePath)` doesn't exist")
            return .notFound()
        }
        
        server.middleware.append { [unowned self] request, header in
            logger.i("Request \(request.id) \(request.method) \(request.path) from \(request.clientIP ?? "")")
            request.onFinished { [unowned self] summary in
                self.logger.i("Request \(summary.requestID) finished with \(summary.responseCode) [\(summary.responseSize)] in \(String(format: "%.3f", summary.durationInSeconds)) seconds")
            }
            return nil
        }
    }
    private func setupLabelEndpoints() {
        // list of labels
        // form to add a new label
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
        
        // list of cropped images presenting label objects
        server["/labelPreview"] = { [unowned self] request, _ in
            guard let labelID = request.queryParams["labelID"]?.decimal, let label = project.objectLabels[safeIndex: labelID] else {
                return .movedTemporarily("/labels")
            }
            
            let previewTemplate = Template.cached(relativePath: "templates/label-preview.tpl.html")
            for (imageIndex, image) in project.inputImages.enumerated() {
                for (objectIndex, object) in project.getObjectsOnImage(imageIndex: imageIndex).enumerated() {
                    guard object.labelID == labelID else {
                        continue
                    }
                    previewTemplate.assign(["imageIndex": "\(imageIndex)",
                                            "objectIndex": objectIndex,
                                            "filename": image.filename,
                                           ], inNest: "image")
                }
                
            }
            previewTemplate["id"] = label.id
            previewTemplate["label"] = label.name
            
            let template = self.pageTemplate
            template["content"] = previewTemplate
            return .ok(.html(wrapTemplate(template)))
        }
        
        // cropper image preview for specified label and object
        server["/preview"] = { [unowned self] request, headers in
            guard let index = request.queryParams.get("imageIndex")?.decimal,
                  let inputImage = project.inputImages[safeIndex: index],
                  let objectIndex = request.queryParams["objectIndex"]?.decimal,
                  let object = project.getObjectsOnImage(imageIndex: index)[safeIndex: objectIndex] else {
                return .notFound()
            }
            let image = try Image(url: inputImage.url)?
                .cropped(to: Rectangle(x: object.imageArea.left,
                                       y: object.imageArea.top,
                                       width: object.imageArea.width,
                                       height: object.imageArea.height))?.export(as: .jpg(quality: 90))
            guard let image else {
                return .notFound()
            }
            
            headers.addHeader("Content-Type", "image/jpeg")
            return .raw(200, "OK", { writer in
                try writer.write(image)
            })
        }
    }

    private func setupImageEndpoints() {
        // list of input images
        server["/images"] = { [unowned self] request, _ in

            let listTemplate = Template.cached(relativePath: "templates/image-list.tpl.html")
            for (index, image) in project.inputImages.enumerated() {
                listTemplate.assign(["imageIndex": "\(index)", "filename": image.filename], inNest: "image")
            }
            let template = self.pageTemplate
            template["content"] = listTemplate
            return .ok(.html(wrapTemplate(template)))
        }
        
        func selectLabelRaw(selectedLabelID: Int? = nil) -> String {
            let selectLabelTemplate = Template.cached(relativePath: "templates/select-label.tpl.html")
            for label in project.objectLabels {
                if label.id == selectedLabelID {
                    selectLabelTemplate.assign(label, inNest: "selected")
                } else {
                    selectLabelTemplate.assign(label, inNest: "option")
                }
            }
            return selectLabelTemplate.output.replacingOccurrences(of: "\n", with: "")
        }
        
        // adding labeled object to an image
        // removing a labeled object from image
        server["/image"] = { [unowned self] request, _ in
            guard let index = request.queryParams.get("imageIndex")?.decimal, let inputImage = project.inputImages[safeIndex: index] else {
                return .movedTemporarily("/images")
            }
            struct Input: Codable {
                let frame: String
                let label: Int
            }
            
            if let input: Input = try? request.formData.decode(), let imageArea = ImageArea(json: input.frame) {
                project.addObject(imageIndex: index, labelID: input.label, imageArea: imageArea)
            }
            if let labelIndexToRemove = request.queryParams.get("removeLabelIndex")?.decimal {
                project.removeObject(imageIndex: index, objectIndex: labelIndexToRemove)
                return .movedTemporarily("/image?imageIndex=\(index)")
            }
            if let type = request.formData["status"], let imageStatus = ImageStatus(rawValue: type) {
                project.setImageStatus(imageIndex: index, status: imageStatus)
            }
            
            
            let template = pageTemplate
            let picTemplate = Template.cached(relativePath: "templates/image-details.tpl.html")
            picTemplate["index"] = index
            picTemplate["nextIndex"] = index.incremented
            picTemplate["prevIndex"] = index.decremented
            picTemplate["imageUrl"] = "/file?imageIndex=\(index)&filename=\(inputImage.filename)"
            picTemplate["filename"] = inputImage.filename
            
            var nextCounter = 0
            for (counter, object) in project.getObjectsOnImage(imageIndex: index).enumerated() {
                let frame = object.imageArea
                picTemplate.assign(["left" : frame.left,
                                    "top": frame.top,
                                    "width": frame.width,
                                    "height": frame.height,
                                    "counter": counter], inNest: "frame")
                picTemplate.assign(["frame" : frame.jsonOneLine!,
                                    "imageIndex": index,
                                    "label": object.labelID,
                                    "selectLabel": selectLabelRaw(selectedLabelID: object.labelID),
                                    "labelIndex": counter,
                                    "counter": counter], inNest: "form")
                nextCounter = counter.incremented
            }
            
            // form to update image type
            let form = Form(url: "/image?imageIndex=\(index)", method: "POST", attributes: ["class" : "bg-light"])
            form.addSelect(name: "status", label: "Image purpose", options: ImageStatus.allCases.map {
                FormSelectModel(label: $0.rawValue, value: $0.rawValue)
            }, selected: project.getImageStatus(imageIndex: index)?.rawValue)
            form.addSubmit(name: "updateType", label: "Save", style: .primary, .small)
            form.addRaw(html: "<hr>")
            picTemplate["imageTypeForm"] = form
            
            
            template["content"] = picTemplate
            let mainTemplate = wrapTemplate(template)
            mainTemplate.addJS(url: "/script.js?counter=\(nextCounter)")
            mainTemplate.addJS(url: "/editor.js?imageIndex=" + index.description)
            return .ok(.html(mainTemplate))
        }
        
        // raw input file
        server["/file"] = { [unowned self] request, _ in
            guard let index = request.queryParams.get("imageIndex")?.decimal, let inputImage = project.inputImages[safeIndex: index] else {
                return .notFound()
            }
            try HttpFileResponse.with(absolutePath: inputImage.url.path, clientCache: .hours(1))
            return .notFound()
        }
        
        // helper js script to edit objects
        server.get["editor.js"] = { request, _ in
            let js = Template.cached(relativePath: "templates/editor.tpl.js")
            js["imageIndex"] = request.queryParams.get("imageIndex")
            return .ok(.js(js))
        }
        
        // helper js script to edit objects
        server.get["/script.js"] = { [unowned self] request, _ in
            let js = Template.cached(relativePath: "templates/script.tpl.js")
            js["previewWidth"] = env.get("PREVIEW_WIDTH") ?? 512
            js["selectLabelRaw"] = selectLabelRaw()
            js["counter"] = request.queryParams.get("counter")?.decimal ?? 0
            return .ok(.js(js))
        }
    }
}
