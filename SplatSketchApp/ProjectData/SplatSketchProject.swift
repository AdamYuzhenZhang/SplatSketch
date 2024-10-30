//
//  SplatSketchProject.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/27/24.
//

import Foundation

enum ProjectError: Error, LocalizedError {
    case projectAlreadyExists
    case failedToCreateFolder(String)
    case projectNotFound
    case encodingFailed
    case writingFailed(String)
    case failedToListProjects(String) // New case for listing projects
    
    var errorDescription: String? {
        switch self {
        case .projectAlreadyExists:
            return "The project already exists."
        case .failedToCreateFolder(let folderName):
            return "Failed to create folder: \(folderName)."
        case .projectNotFound:
            return "Project not found."
        case .encodingFailed:
            return "Failed to encode data."
        case .writingFailed(let detail):
            return "Failed to write data: \(detail)."
        case .failedToListProjects(let message):
            return "Failed to list projects: \(message)"
        }
    }
}

public class SplatSketchProject {
    let projectName: String
    // let canvasNames: [String] = []  // Names of all canvases in this project
    
    init(projectName: String) {
        self.projectName = projectName
    }
    // Project info
    // Project ply file
    // Project 2D Canvas files & their camera information
    
    // Initialize Project Directory
    func initialize() throws {
        let fileManager = FileManager.default
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let projectURL = directory.appendingPathComponent(projectName)
        do {
            try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true, attributes: nil)
            print("Created project folder at \(projectURL.path)")
        } catch {
            throw ProjectError.failedToCreateFolder("Project folder")
        }
        let subfolders = ["Canvas", "Image", "Model"]
        for folder in subfolders {
            let folderURL = projectURL.appendingPathComponent(folder)
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                print("Created \(folder) folder at \(folderURL.path)")
            } catch {
                throw ProjectError.failedToCreateFolder(folder)
            }
        }
    }
    
    
}
