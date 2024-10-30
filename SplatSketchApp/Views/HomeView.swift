//
//  HomeView.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/30/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @Environment(AppManager.self) var appManager
    @State private var isPickingFile: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("Splat Sketch App")
                .font(.largeTitle)
                .padding()
            Spacer()
            VStack {
                /*
                Button("Create New Test Project") {
                    openWindow(value: ModelIdentifier.sampleBox)
                }
                .padding()
                .buttonStyle(.borderedProminent)
                 */
                Button("Create New Project Test") {
                    appManager.createNewProject(projectName: "Test Project")
                }
                .padding()
                .buttonStyle(.borderedProminent)
                
                Button("Load File Test") {
                    isPickingFile = true
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .fileImporter(
                    isPresented: $isPickingFile,
                    allowedContentTypes: [
                        UTType(filenameExtension: "ply")!,
                        UTType(filenameExtension: "splat")!
                    ],
                    allowsMultipleSelection: false
                ) { result in
                    isPickingFile = false
                    switch result {
                    case .success(let urls):
                        if let firstURL = urls.first {
                            appManager.loadGSFile(url: firstURL)
                        }
                    case .failure(let error): break
                        // appManager.errorMessage = "Failed to pick file: \(error.localizedDescription)"
                    }
                }
            }
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
