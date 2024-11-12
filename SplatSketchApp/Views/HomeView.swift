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
    @State private var projectNameInput: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("Splat Sketch App")
                .font(.largeTitle)
                .padding()
            VStack {
                TextField("Project Name", text: $projectNameInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 300)
                    .padding()
                
                HStack {
                    Spacer()
                    Button("Create New Project") {
                        appManager.createNewProject(projectName: projectNameInput)
                    }
                    .padding()
                    .buttonStyle(.bordered)
                    
                    Button("New Project From File") {
                        isPickingFile = true
                    }
                    .padding()
                    .buttonStyle(.bordered)
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
                                appManager.createNewProjectFromFile(projectName: projectNameInput, url: firstURL)
                            }
                        case .failure(let error):
                            print("Failed to pick file: \(error.localizedDescription)")
                            break
                        }
                    }
                    
                    Button("Load File Test") {
                        isPickingFile = true
                    }
                    .padding()
                    .buttonStyle(.bordered)
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
                                appManager.loadGSFilePicker(url: firstURL)
                            }
                        case .failure(let error):
                            print("Failed to pick file: \(error.localizedDescription)")
                            break
                        }
                    }
                    Spacer()
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(appManager.allProjects, id: \.self) { project in
                            Button(action: {
                                print(project)
                                appManager.openProject(projectName: project)
                            }) {
                                Text (project)
                                    .padding()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } .padding()
            }
            Spacer()
        }
        .onAppear {
            appManager.initializeApp()
        }
    }
}
