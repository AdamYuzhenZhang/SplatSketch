#if os(iOS) || os(macOS)

import Metal
import MetalKit
import MetalSplatter
import os
import SampleBoxRenderer
import simd
import SwiftUI
import Combine

class MetalKitSceneRenderer: NSObject, MTKViewDelegate {
    private static let log =
        Logger(subsystem: Bundle.main.bundleIdentifier!,
               category: "MetalKitSceneRenderer")

    let metalKitView: MTKView
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    var model: ModelIdentifier? // GS model
    //var planes: [ModelIdentifier] = []
    var modelRenderer: (any ModelRenderer)?
    var modelRenderer2: (any ModelRenderer)?  // For testing
    var canvasRenderer: CanvasRenderer?
    // Added
    //var camera = Camera()
    var appManager: AppManager

    let inFlightSemaphore = DispatchSemaphore(value: Constants.maxSimultaneousRenders)
    var drawableSize: CGSize = .zero

    init?(_ metalKitView: MTKView, appManager: AppManager) {
        self.appManager = appManager
        self.device = metalKitView.device!
        guard let queue = self.device.makeCommandQueue() else { return nil }
        self.commandQueue = queue
        self.metalKitView = metalKitView
        metalKitView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float
        metalKitView.sampleCount = 1
        //metalKitView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        metalKitView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        // added
        metalKitView.isOpaque = false
        metalKitView.backgroundColor = UIColor.clear
        //metalKitView.isOpaque = true
        //metalKitView.backgroundColor = UIColor.gray
        // For macOS, metalKitView.layer?.backgroundColor = NSColor.clear.cgColor
        super.init()
        appManager.registerRenderer(self)
    }

    func load(_ model: ModelIdentifier?) async throws {
        guard model != self.model else { return }
        self.model = model
        print("Loading \(model?.description ?? "Unknown model")")

        modelRenderer = nil
        switch model {
        case .gaussianSplat(let url):
            do {
                let splat = try await SplatRenderer(device: device,
                                                    colorFormat: metalKitView.colorPixelFormat,
                                                    depthFormat: metalKitView.depthStencilPixelFormat,
                                                    sampleCount: metalKitView.sampleCount,
                                                    maxViewCount: 1,
                                                    maxSimultaneousRenders: Constants.maxSimultaneousRenders)
                try await splat.read(from: url)
                modelRenderer = splat
                print("Loaded Splat from \(url.path)")
                
            } catch {
                print("Failed to load Splat from \(url.path): \(error)")
            }
            
            // Initialize CanvasRenderer
            do {
                let canvas = try await CanvasRenderer(device: device,
                                                colorFormat: metalKitView.colorPixelFormat,
                                                depthFormat: metalKitView.depthStencilPixelFormat,
                                                sampleCount: metalKitView.sampleCount)
                self.canvasRenderer = canvas
            } catch {
                Self.log.error("Failed to initialize CanvasRenderer: \(error.localizedDescription)")
            }
        case .sampleBox:
            modelRenderer = try! await SampleBoxRenderer(device: device,
                                                         colorFormat: metalKitView.colorPixelFormat,
                                                         depthFormat: metalKitView.depthStencilPixelFormat,
                                                         sampleCount: metalKitView.sampleCount,
                                                         maxViewCount: 1,
                                                         maxSimultaneousRenders: Constants.maxSimultaneousRenders)
        case .none:
            break
        }
    }
    
    func addTest() async throws {
        modelRenderer2 = nil
        modelRenderer2 = try! await SampleBoxRenderer(device: device,
                                                     colorFormat: metalKitView.colorPixelFormat,
                                                     depthFormat: metalKitView.depthStencilPixelFormat,
                                                     sampleCount: metalKitView.sampleCount,
                                                     maxViewCount: 1,
                                                     maxSimultaneousRenders: Constants.maxSimultaneousRenders)
    }
    func removeTest() {
        modelRenderer2 = nil
    }
    
    // Add canvas to canvas renderer
    func loadCanvas(canvas: Canvas) {
        guard let texture = self.loadTexture(from: canvas.textureURL) else { return }
        canvasRenderer?.addCanvas(canvas: canvas, texture: texture)
    }
    func removeCanvas(name: String) {
        canvasRenderer?.removeCanvas(name: name)
    }

    private var viewport: ModelRendererViewportDescriptor {
        /*
         let projectionMatrix = matrix_perspective_right_hand(fovyRadians: Float(Constants.fovy.radians),
         aspectRatio: Float(drawableSize.width / drawableSize.height),
         nearZ: 0.1,
         farZ: 100.0)
         
         let rotationMatrix = matrix4x4_rotation(radians: Float(rotation.radians),
         axis: Constants.rotationAxis)
         let translationMatrix = matrix4x4_translation(0.0, 0.0, Constants.modelCenterZ)
         // Turn common 3D GS PLY files rightside-up. This isn't generally meaningful, it just
         // happens to be a useful default for the most common datasets at the moment.
         let commonUpCalibration = matrix4x4_rotation(radians: .pi, axis: SIMD3<Float>(0, 0, 1))
         
         let viewport = MTLViewport(originX: 0, originY: 0, width: drawableSize.width, height: drawableSize.height, znear: 0, zfar: 1)
         
         return ModelRendererViewportDescriptor(viewport: viewport,
         projectionMatrix: projectionMatrix,
         viewMatrix: translationMatrix * rotationMatrix * commonUpCalibration,
         screenSize: SIMD2(x: Int(drawableSize.width), y: Int(drawableSize.height)))
         */
        
        let aspectRatio = Float(drawableSize.width / drawableSize.height)
        appManager.activeCamera?.aspectRatio = aspectRatio
        let fovy = appManager.activeCamera?.fovy
        let projectionMatrix = matrix_perspective_right_hand(fovyRadians: Float(fovy ?? 60 * (.pi / 180)), aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100.0)
        
        
        //let viewMatrix = camera.viewMatrix()
        let viewMatrix = appManager.getCameraViewMatrix()
        
        let viewport = MTLViewport(originX: 0, originY: 0, width: drawableSize.width, height: drawableSize.height, znear: 0, zfar: 1)
        
        return ModelRendererViewportDescriptor(viewport: viewport,
                                               projectionMatrix: projectionMatrix,
                                               viewMatrix: viewMatrix,
                                               screenSize: SIMD2(x: Int(drawableSize.width), y: Int(drawableSize.height)))
    }

    func draw(in view: MTKView) {
        guard let modelRenderer else { return }
        guard let drawable = view.currentDrawable else { return }

        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            inFlightSemaphore.signal()
            return
        }
        
        let semaphore = inFlightSemaphore
        commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
            semaphore.signal()
        }

        do {
            try modelRenderer.render(viewports: [viewport],
                                     colorTexture: view.multisampleColorTexture ?? drawable.texture,
                                     colorStoreAction: view.multisampleColorTexture == nil ? .store : .multisampleResolve,
                                     depthTexture: view.depthStencilTexture,
                                     rasterizationRateMap: nil,
                                     renderTargetArrayLength: 0,
                                     to: commandBuffer)
            if let renderer2 = modelRenderer2 {
                try renderer2.render(viewports: [viewport],
                                         colorTexture: view.multisampleColorTexture ?? drawable.texture,
                                         colorStoreAction: view.multisampleColorTexture == nil ? .store : .multisampleResolve,
                                         depthTexture: view.depthStencilTexture,
                                         rasterizationRateMap: nil,
                                         renderTargetArrayLength: 0,
                                         to: commandBuffer)
            }
        } catch {
            Self.log.error("Unable to render scene: \(error.localizedDescription)")
        }
        
        if let canvas = canvasRenderer {
            do {
                try canvas.render(viewports: [viewport],
                                  colorTexture: view.multisampleColorTexture ?? drawable.texture,
                                  colorStoreAction: view.multisampleColorTexture == nil ? .store : .multisampleResolve,
                                  depthTexture: view.depthStencilTexture,
                                  rasterizationRateMap: nil,
                                  renderTargetArrayLength: 0,
                                  to: commandBuffer)
            } catch {
                print("Unable to render canvas: \(error.localizedDescription)")
            }
        }

        commandBuffer.present(drawable)

        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        drawableSize = size
    }
    
    private func loadTexture(from url: URL) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        do {
            let texture = try textureLoader.newTexture(URL: url, options: [
                MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.bottomLeft.rawValue,
                MTKTextureLoader.Option.SRGB: NSNumber(value: true)
            ])
            return texture
        } catch {
            Self.log.error("Failed to load texture from \(url.path): \(error.localizedDescription)")
            return nil
        }
    }
    
}

#endif // os(iOS) || os(macOS)
