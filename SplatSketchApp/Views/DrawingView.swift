//
//  DrawingView.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/30/24.
//

import SwiftUI

struct DrawingView: View {
    @Environment(AppManager.self) var appManager
    
    @State private var canvasNameInput: String = ""
    @State private var backgroundColor: Color = .gray
    
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(backgroundColor)
                .edgesIgnoringSafeArea(.all)
            // Metal Kit
            if let url = appManager.selectedGSURL {
                MetalKitSceneView(modelIdentifier: ModelIdentifier.gaussianSplat(url))
                    .edgesIgnoringSafeArea(.all)
                // MetalKitSceneView(modelIdentifier: .sampleBox)
            } else {
                Text("No GS Model Selected")
            }
            
            // Canvas
            if appManager.appState == .drawing {
                CanvasView()
                    .background(Color.clear)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Button("Close Canvas") {
                        appManager.closeCanvas()
                        
                    }
                    .padding()
                    .buttonStyle(.bordered)
                    Spacer()
                }
            } else {
                HStack {
                    VStack {
                        
                        Button("TestAddCube") {
                            appManager.addCube()
                        }
                        .padding()
                        .buttonStyle(.bordered)
                        
                        Button("TestRemoveCube") {
                            appManager.removeCube()
                        }
                        .padding()
                        .buttonStyle(.bordered)
                        ColorPicker("Background", selection: $backgroundColor)
                            .frame(maxWidth: 180)
                            .padding()

                        
                        TextField("Canvas Name", text: $canvasNameInput)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 200)
                            .padding()
                        
                        Button("Create New Canvas") {
                            appManager.createNewCanvas(name: canvasNameInput)
                        }
                        .padding()
                        .buttonStyle(.bordered)
                        
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 10) {
                                ForEach(appManager.allCanvases, id: \.self) { canvas in
                                    Button(action: {
                                        print(canvas)
                                        appManager.openCanvas(name: canvas)
                                    }) {
                                        Text(canvas).padding()
                                    }.buttonStyle(.bordered)
                                }
                            }
                        }
                        
                        Button("Close Project") {
                            appManager.closeProject()
                        }
                        .padding()
                        .buttonStyle(.bordered)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            canvasNameInput = ""
            do { try appManager.getAllCanvases() } catch {
                print("Error: \(error)")
            }
        }
    }
}

#Preview {
    DrawingView()
}
