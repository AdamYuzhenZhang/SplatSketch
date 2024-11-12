//
//  AppManager+Canvas.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/29/24.
//

import Foundation
import PencilKit

extension AppManager {
    // Get canvas names under projectName>Canvases
    func getAllCanvases() throws {
        guard let project = self.activeProject else { return }
        // Project is indeed active
        self.allCanvases = []  // Reset active Project
        let fileManager = FileManager.default
        guard let projectURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ProjectError.failedToListProjects("Unable to locate the Documents directory.")
        }
        let documentsURL = projectURL.appendingPathComponent(project.projectName).appendingPathComponent("Canvas")
        do {
            let contents = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
            
            let canvasFiles = contents.filter { url in
                (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == false
            }.map { $0.lastPathComponent }
            //print("canvasFiles: \(canvasFiles)")
            self.allCanvases = canvasFiles
        } catch {
            throw ProjectError.failedToListProjects("Error accessing Documents directory: \(error.localizedDescription)")
        }
    }
    
    
    func createNewCanvas(name: String) {
        // create a canvas object
        guard let camera = self.activeCamera else { return }
        guard let textureURL = getImageURL(name: name) else { return }
        
        self.activeCanvas = Canvas(name: name, camera: camera, textureURL: textureURL)
        // change appState to drawing
        self.appState = .drawing
    }
    
    func openCanvas(name: String) {
        // load canvas from file
        guard let canvasData = loadCanvasData(name: name) else { return }
        // get camera info from canvasData and update camera
        guard let camera = self.activeCamera else { return }
        camera.updateFromCameraData(canvasData.cameraData)
        // get canvas info from canvas data and update canvas
        guard let textureURL = getImageURL(name: canvasData.name) else { return }
        self.activeCanvas = Canvas(name: canvasData.name, camera: camera, textureURL: textureURL)
        do {
            let drawing = try PKDrawing(data: canvasData.drawingData)
            self.activeCanvas?.drawing = drawing
            print("Drawing loaded successfully.")
        } catch {
            print("Error loading drawing: \(error.localizedDescription)")
            return
        }
        // Remove canvas png from scene // TBD
        self.removeCanvasFromMTK(name: canvasData.name)
        
        self.appState = .drawing
    }
    
    // close the current canvas
    func closeCanvas() {
        // save contents in canvasView to activeCanvas // saved every stroke already
        // save canvas to file
        self.saveCanvasDrawing()
        // export canvas png
        self.exportCanvasImage()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            // Delay to make sure saving completes
            // load canvas png to scene // TBD
            guard let activeCanvas = self.activeCanvas else { return }
            self.loadCanvasToMTK(canvas: activeCanvas)
            
            // close canvas
            self.activeCanvas = nil
            self.appState = .threeD
            
            // get all canvases
            // update canvas list
            do {
                try self.getAllCanvases()
            } catch {
                print("Error getting all canvases: \(error.localizedDescription)")
            }
        }
        
    }
    
    // adds canvas to the metal kit renderer
    func loadCanvasToMTK(canvas: Canvas) {
        print("load to mtk")
        self.metalKitSceneRenderer?.loadCanvas(canvas: canvas)
    }
    func removeCanvasFromMTK(name: String) {
        print("remove from mtk")
        self.metalKitSceneRenderer?.removeCanvas(name: name)
    }
    // First opened app, add all canvases, also remove all when closing the app
    func loadAllCanvasesToMTK() {
        
    }
    
    // Turn the activeCanvas into CanvasData and save it
    func saveCanvasDrawing() {
        guard let activeCanvas = self.activeCanvas else { return }
        let canvasData: CanvasData = CanvasData(canvas: activeCanvas)
        guard let directory = self.getCanvasURL() else { return }
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(canvasData)
            try data.write(to: directory)
            print("Drawing saved successfully at \(directory).")
        } catch {
            print("Error saving drawing: \(error.localizedDescription)")
        }
    }
    func exportCanvasImage() {
        guard let activeCanvas = self.activeCanvas else { return }
        guard let from = self.canvasBounds else { return }
        guard let scale = self.canvasScale else { return }
        guard let imageURL = self.getImageURL() else { return }
        //print(from)
        //print(scale)
        let image = activeCanvas.drawing.image(from: from, scale: scale)
        // Convert the UIImage to PNG data
        if let pngData = image.pngData() {
            // Save the PNG data to a file in the Documents directory
            do {
                try pngData.write(to: imageURL)
                print("Drawing exported as PNG file at \(imageURL)")
            } catch {
                print("Error saving PNG file: \(error.localizedDescription)")
            }
        } else {
            print("Failed to convert image to PNG data.")
        }
    }
    
    // Load canvas with name and return as CanvasData
    func loadCanvasData(name: String) -> CanvasData? {
        guard let directory = self.getCanvasURL(name: name) else { return nil }
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: directory)
            let canvasData = try decoder.decode(CanvasData.self, from: data)
            return canvasData
        } catch {
            print("Error loading drawing: \(error.localizedDescription)")
            return nil
        }
    }
    
}
