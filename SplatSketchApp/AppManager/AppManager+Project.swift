//
//  AppManager+Project.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/29/24.
//

import Foundation

extension AppManager {
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
            } catch {
                print("Error getting all canvases: \(error.localizedDescription)")
            }
        }
    }
    
    // load a GS file at url
    func loadGSFile(url: URL) {
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
        appState = .threeD
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 30) {
            url.stopAccessingSecurityScopedResource()
        }
    }
}
