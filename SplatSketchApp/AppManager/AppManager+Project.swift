//
//  AppManager+Project.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/29/24.
//

import Foundation

extension AppManager {
    func initializeApp() {
        do {
            try getAllProjects()
        } catch {
            print("Error: \(error)")
        }
    }
    // Get all projects from folder, save names in allProjects
    func getAllProjects() throws {
        self.allProjects = []  // Reset active Project
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ProjectError.failedToListProjects("Unable to locate the Documents directory.")
        }
        do {
            let contents = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
            
            let projectFolders = contents.filter { url in
                (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
            }.map { $0.lastPathComponent }
            
            self.allProjects = projectFolders
        } catch {
            throw ProjectError.failedToListProjects("Error accessing Documents directory: \(error.localizedDescription)")
        }
    }
    
    
    func createNewProject(projectName: String) {
        self.activeProject = SplatSketchProject(projectName: projectName)
        do {
            try self.activeProject?.initialize()
        } catch {
            print("Error initializing new project: \(error.localizedDescription)")
            self.activeProject = nil
        }
        self.allCanvases = []  // Reset canvas
        self.loadEmptyGSFile()
        if self.activeCamera != nil {
            // opened successfully
            self.appState = .threeD
        }
    }
    func createNewProjectFromFile(projectName: String, url: URL) {
        self.activeProject = SplatSketchProject(projectName: projectName)
        do {
            try self.activeProject?.initialize()
        } catch {
            print("Error initializing new project: \(error.localizedDescription)")
            self.activeProject = nil
        }
        self.allCanvases = []  // Reset canvas
        self.loadGSFileTest(url: url)
        if self.activeCamera != nil {
            // opened successfully
            self.appState = .threeD
        }
    }
    
    func openProject(projectName: String) {
        do {
            try self.getAllProjects()  // get all projects again to make sure no errors
        } catch {
            print("Error getting all projects: \(error.localizedDescription)")
        }
        // check if project name is in all Project, otherwise stop
        if self.allProjects.contains(projectName) {
            // open project, just create a new project
            self.activeProject = SplatSketchProject(projectName: projectName)
            // get all canvases
            do {
                try self.getAllCanvases()
                // loadGS
                guard let destinationURL = getGSFileURL() else { return }
                loadGSFile(url: destinationURL)
            } catch {
                print("Error getting all canvases: \(error.localizedDescription)")
            }
        }
    }
    
    func closeProject() {
        self.activeCamera = nil
        self.activeCanvas = nil
        self.allCanvases = []
        self.activeProject = nil
        self.appState = .home
    }
    
    // load a GS file at url
    func loadGSFilePicker(url: URL) {
        self.activeCamera = Camera()
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to start accessing security scoped resource.")
            return
        }

        let validExtensions = ["ply", "splat"]
        let fileExtension = url.pathExtension.lowercased()
        
        //print("Loading GS file:")
        //print(url.absoluteString)
        
        guard validExtensions.contains(fileExtension) else {
            return  // unsupported file type
        }
        
        // Assign the selected URL
        self.selectedGSURL = url
        
        // Transition to 3d state
        self.appState = .threeD
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 30) {
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    // load a GS file at url
    func loadGSFile(url: URL) {
        self.activeCamera = Camera()
        // Assign the selected URL
        self.selectedGSURL = url
        // Transition to 3d state
        self.appState = .threeD
    }
    
    
    
    func loadEmptyGSFile() {
        if let fileURL = Bundle.main.url(forResource: "splat", withExtension: "ply") {
            print("File URL: \(fileURL)")
            
            // Copy file to project folder
            let fileManager = FileManager.default
            guard let destinationURL = getGSFileURL() else { return }
            
            if fileManager.fileExists(atPath: destinationURL.path) {
                try? fileManager.removeItem(at: destinationURL)
            }
            
            do {
                try fileManager.copyItem(at: fileURL, to: destinationURL)
                print("File copied to \(destinationURL)")
                self.selectedGSURL = destinationURL
                self.activeCamera = Camera()
            } catch {
                print("Failed to copy file: \(error.localizedDescription)")
            }
        } else {
            print("File not found.")
        }
    }
    func loadGSFileTest(url: URL) {
        let fileURL = url
        print("File URL: \(fileURL)")
        
        // Copy file to project folder
        let fileManager = FileManager.default
        guard let destinationURL = getGSFileURL() else { return }
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try? fileManager.removeItem(at: destinationURL)
        }
        
        do {
            try fileManager.copyItem(at: fileURL, to: destinationURL)
            print("File copied to \(destinationURL)")
            self.selectedGSURL = destinationURL
            self.activeCamera = Camera()
        } catch {
            print("Failed to copy file: \(error.localizedDescription)")
        }
        
    }
    
    
    
    // File URLs
    
    func getGSFileURL() -> URL? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        guard let project = self.activeProject else { return nil }
        let destinationURL = documentsURL.appendingPathComponent(project.projectName).appendingPathComponent("Model").appendingPathComponent("splat.ply")
        return destinationURL
    }
    
    // Project > Canvas > CanvasName
    func getCanvasURL(name: String? = nil) -> URL? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        guard let project = self.activeProject else { return nil }
        if let name {
            let destinationURL = documentsURL.appendingPathComponent(project.projectName).appendingPathComponent("Canvas").appendingPathComponent(name)
            return destinationURL
        } else {
            guard let canvas = self.activeCanvas else { return nil }
            let destinationURL = documentsURL.appendingPathComponent(project.projectName).appendingPathComponent("Canvas").appendingPathComponent(canvas.name)
            return destinationURL
        }
    }
    
    // Project > Image > name.png
    func getImageURL(name: String? = nil) -> URL? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        guard let project = self.activeProject else { return nil }
        
        if let name {
            let destinationURL = documentsURL.appendingPathComponent(project.projectName).appendingPathComponent("Image").appendingPathComponent(name + ".png")
            return destinationURL
        } else {
            guard let canvas = self.activeCanvas else { return nil }
            let destinationURL = documentsURL.appendingPathComponent(project.projectName).appendingPathComponent("Image").appendingPathComponent(canvas.name + ".png")
            return destinationURL
        }
    }
    
}
