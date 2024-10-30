//
//  AppManager.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/29/24.
//

import Foundation

@Observable
class AppManager {
    var activeProject: SplatSketchProject?
    var activeCanvas: Canvas?
    var appState: AppState = .home
    var activeCamera: Camera?
    
    var selectedGSURL: URL?  // the selected GS file, temp
    
    var allProjects: [String] = []
    var allCanvases: [String] = []  // In active project
    
}
