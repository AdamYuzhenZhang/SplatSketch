//
//  AppManager+Canvas.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/29/24.
//

import Foundation

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
        let documentsURL = projectURL.appendingPathComponent(project.projectName).appendingPathExtension("Canvas")
        do {
            let contents = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
            
            let canvasFiles = contents.filter { url in
                (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == false
            }.map { $0.lastPathComponent }
            
            self.allCanvases = canvasFiles
        } catch {
            throw ProjectError.failedToListProjects("Error accessing Documents directory: \(error.localizedDescription)")
        }
    }
    
    func createNewCanvas(name: String) {
        // create a canvas object
        self.activeCanvas = Canvas(name: name)
        // change appState to drawing
        self.appState = .drawing
        
    }
    
    
}
