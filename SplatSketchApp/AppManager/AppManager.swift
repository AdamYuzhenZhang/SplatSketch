//
//  AppManager.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/29/24.
//

import Foundation
import PencilKit

@Observable
class AppManager {
    var activeProject: SplatSketchProject?
    var activeCanvas: Canvas?
    var appState: AppState = .home
    var activeCamera: Camera?
    
    var metalKitSceneRenderer: MetalKitSceneRenderer?
    //@Published var canvasView: PKCanvasView = PKCanvasView()

    var canvasBounds: CGRect?
    var canvasScale: CGFloat?
    
    var selectedGSURL: URL?  // the selected GS file, temp
    
    var allProjects: [String] = []
    var allCanvases: [String] = []  // In active project
    
    func registerRenderer(_ renderer: MetalKitSceneRenderer) {
        self.metalKitSceneRenderer = renderer
    }
    
    func addCube() {
        Task {
            do {
                try await metalKitSceneRenderer?.addTest()
            } catch {
                print("Error adding cube: \(error)")
            }
        }
    }
    func removeCube() {
        metalKitSceneRenderer?.removeTest()
    }
    
    
}
