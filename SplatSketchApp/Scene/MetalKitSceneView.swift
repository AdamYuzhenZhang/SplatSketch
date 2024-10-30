#if os(iOS) || os(macOS)

import SwiftUI
import MetalKit

#if os(macOS)
private typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
private typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalKitSceneView: ViewRepresentable {
    @Environment(AppManager.self) var appManager
    var modelIdentifier: ModelIdentifier?  // Set to .gaussianSplat(url)

    class Coordinator {
        var renderer: MetalKitSceneRenderer?
        // Adding gestures
        @objc func handleRotationPanGesture(_ gesture: UIPanGestureRecognizer) {
            guard let renderer = renderer else { return }
            let translation = gesture.translation(in: gesture.view)
            let deltaX = Float(translation.x)
            let deltaY = Float(translation.y)
            renderer.appManager.activeCamera?.rotate(deltaX: deltaX, deltaY: deltaY)
            //renderer.camera.rotate(deltaX: deltaX, deltaY: deltaY)
            gesture.setTranslation(.zero, in: gesture.view)
        }
        
        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            guard let renderer = renderer else { return }
            let translation = gesture.translation(in: gesture.view)
            let deltaX = Float(translation.x)
            let deltaY = Float(translation.y)
            renderer.appManager.activeCamera?.pan(deltaX: deltaX, deltaY: deltaY)
            //renderer.camera.pan(deltaX: deltaX, deltaY: deltaY)
            gesture.setTranslation(.zero, in: gesture.view)
        }
        
        @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
            guard let renderer = renderer else { return }
            let scale = Float(gesture.scale) - 1.0
            renderer.appManager.activeCamera?.zoom(delta: -scale)
            //renderer.camera.zoom(delta: -scale)
            gesture.scale = 1.0
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

#if os(macOS)
    func makeNSView(context: NSViewRepresentableContext<MetalKitSceneView>) -> MTKView {
        makeView(context.coordinator)
    }
#elseif os(iOS)
    func makeUIView(context: UIViewRepresentableContext<MetalKitSceneView>) -> MTKView {
        makeView(context: context, coordinator: context.coordinator)
    }
#endif

    private func makeView(context: Context, coordinator: Coordinator) -> MTKView {
        let metalKitView = MTKView()

        if let metalDevice = MTLCreateSystemDefaultDevice() {
            metalKitView.device = metalDevice
        }

        let renderer = MetalKitSceneRenderer(metalKitView, appManager: appManager)
        coordinator.renderer = renderer
        metalKitView.delegate = renderer

        // Touch input
        metalKitView.isMultipleTouchEnabled = true
        addGestureRecognizers(to: metalKitView, context: context)
        
        // print(modelIdentifier?.description ?? "Invalid")
        Task {
            do {
                try await renderer?.load(modelIdentifier)
            } catch {
                print("Error loading model: \(error.localizedDescription)")
            }
        }

        return metalKitView
    }
    
    // Added
    private func addGestureRecognizers(to view: MTKView, context: Context) {
        // One-finger pan for rotation
        let rotationPanGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRotationPanGesture(_:)))
        rotationPanGesture.minimumNumberOfTouches = 1
        rotationPanGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(rotationPanGesture)
        
        // Two-finger pan for panning
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        panGesture.minimumNumberOfTouches = 2
        view.addGestureRecognizer(panGesture)
        
        // Pinch for zoom
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGesture)
    }

#if os(macOS)
    func updateNSView(_ view: MTKView, context: NSViewRepresentableContext<MetalKitSceneView>) {
        updateView(context.coordinator)
    }
#elseif os(iOS)
    func updateUIView(_ view: MTKView, context: UIViewRepresentableContext<MetalKitSceneView>) {
        updateView(context.coordinator)
    }
#endif

    private func updateView(_ coordinator: Coordinator) {
        guard let renderer = coordinator.renderer else { return }
        Task {
            do {
                try await renderer.load(modelIdentifier)
            } catch {
                print("Error loading model: \(error.localizedDescription)")
            }
        }
    }
}

#endif // os(iOS) || os(macOS)
