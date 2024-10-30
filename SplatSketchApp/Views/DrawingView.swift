//
//  DrawingView.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/30/24.
//

import SwiftUI

struct DrawingView: View {
    @Environment(AppManager.self) var appManager
    var body: some View {
        ZStack {
            // Metal Kit
            if let url = appManager.selectedGSURL {
                MetalKitSceneView(modelIdentifier: ModelIdentifier.gaussianSplat(url))
                // MetalKitSceneView(modelIdentifier: .sampleBox)
            } else {
                Text("No GS Model Selected")
            }
            
            // Canvas
            if appManager.appState == .drawing {
                CanvasView()
                    .background(Color.clear)
            }
            
            VStack {
                Text("Control Buttons")
                    .padding()
                Text("\(appManager.appState)")
                    .padding()
                Spacer()
            }
        }
    }
}

#Preview {
    DrawingView()
}
