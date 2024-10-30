import SwiftUI
import RealityKit
import PencilKit
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(AppManager.self) var appManager
    //let appManager: AppManager
    
    //@State private var isPickingFile = false
    //@State private var canvasView = PKCanvasView()
    //@State private var isDrawing = true
    //@State private var strokesDescription: String = ""
    
#if os(macOS)
    @Environment(\.openWindow) private var openWindow
#elseif os(iOS)
    /*
     @State private var navigationPath = NavigationPath()
     
     private func openWindow(value: ModelIdentifier) {
     navigationPath.append(value)
     }
     */
    
#elseif os(visionOS)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @State var immersiveSpaceIsShown = false
    
    private func openWindow(value: ModelIdentifier) {
        Task {
            switch await openImmersiveSpace(value: value) {
            case .opened:
                immersiveSpaceIsShown = true
            case .error, .userCancelled:
                break
            @unknown default:
                break
            }
        }
    }
#endif
    
    var body: some View {
#if os(macOS) || os(visionOS)
        mainView
#elseif os(iOS)
        switch appManager.appState {
        case .home:
            HomeView()
        case .drawing, .threeD:
            DrawingView()
        }
        
        /*
        NavigationStack(path: $navigationPath) {
            mainView
                .navigationDestination(for: ModelIdentifier.self) { modelIdentifier in
                    ZStack {
                        MetalKitSceneView(modelIdentifier: modelIdentifier)
                            .environment(appManager)
                            .navigationTitle(modelIdentifier.description)
                        if isDrawing {
                            ZStack {
                                CanvasView(canvasView: $canvasView, strokesDescription: $strokesDescription)
                                    .environment(appManager)
                                //.frame(width: geometry.size.width / 2, height: geometry.size.height)
                                //.background(Color.white)
                                    .background(Color.clear)
                                HStack {
                                    ScrollView {
                                        Text(strokesDescription)
                                            .padding()
                                            .foregroundColor(.black)
                                    }
                                    .frame(maxWidth: 300, maxHeight: 400) // Adjust height as needed
                                    .background(Color.white.opacity(0.3))
                                    Spacer()
                                    
                                }
                            }
                        }
                        VStack {
                            HStack {
                                Button(isDrawing ? "Pause Drawing" : "Resume Drawing") {
                                    isDrawing.toggle()
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                                
                                Button(action: {
                                    let canvas = CanvasView(canvasView: $canvasView, strokesDescription: $strokesDescription)
                                    canvas.saveDrawing()
                                }) {
                                    Text("Save Drawing")
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                                
                                Button(action: {
                                    let canvas = CanvasView(canvasView: $canvasView, strokesDescription: $strokesDescription)
                                    canvas.loadDrawing()
                                }) {
                                    Text("Load Drawing")
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                                
                                Button(action: {
                                    let canvas = CanvasView(canvasView: $canvasView, strokesDescription: $strokesDescription)
                                    canvas.printStroks()
                                }) {
                                    Text("Print Strokes")
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                                /*
                                 Button(action: {
                                 let canvas = CanvasView(canvasView: $canvasView, strokesDescription: $strokesDescription)
                                 canvas.loadStrokesFromFile()
                                 }) {
                                 Text("Load Strokes")
                                 }
                                 */
                                Button(action: {
                                    let canvas = CanvasView(canvasView: $canvasView, strokesDescription: $strokesDescription)
                                    canvas.exportDrawingAsImage()
                                }) {
                                    Text("Export as Image")
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                                
                            }.padding()
                            Spacer()
                        }
                    }
                }
        }
        */
#endif // os(iOS)
    }
    
    /*
     @ViewBuilder
    var mainView: some View {
        VStack {
            Spacer()
            
            Text("Splat Sketch App")
            
            Spacer()
            
            HStack {
                Button("Create New Test Project") {
                    openWindow(value: ModelIdentifier.sampleBox)
                }
                .padding()
                .buttonStyle(.borderedProminent)
                Button("Load Existing Project") {
                    isPickingFile = true
                }
                .padding()
                .buttonStyle(.borderedProminent)
                
            }
            Spacer()
            
            Button("Read Scene File") {
                isPickingFile = true
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(isPickingFile)
#if os(visionOS)
            .disabled(immersiveSpaceIsShown)
#endif
            .fileImporter(isPresented: $isPickingFile,
                          allowedContentTypes: [
                            UTType(filenameExtension: "ply")!,
                            UTType(filenameExtension: "splat")!,
                          ]) {
                              isPickingFile = false
                              switch $0 {
                              case .success(let url):
                                  _ = url.startAccessingSecurityScopedResource()
                                  Task {
                                      // This is a sample app. In a real app, this should be more tightly scoped, not using a silly timer.
                                      try await Task.sleep(for: .seconds(10))
                                      url.stopAccessingSecurityScopedResource()
                                  }
                                  openWindow(value: ModelIdentifier.gaussianSplat(url))
                              case .failure:
                                  break
                              }
                          }
            
            Spacer()
            
            Button("Show Sample Box") {
                openWindow(value: ModelIdentifier.sampleBox)
            }
            .padding()
            .buttonStyle(.borderedProminent)
#if os(visionOS)
            .disabled(immersiveSpaceIsShown)
#endif
            
            Spacer()
            
#if os(visionOS)
            Button("Dismiss Immersive Space") {
                Task {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
            .disabled(!immersiveSpaceIsShown)
            
            Spacer()
#endif // os(visionOS)
        }
    }
    */
}
