//
//  CanvasRenderer.swift
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/30/24.
//

import Metal
import MetalKit
import simd
import os

public class CanvasRenderer: ModelRenderer {
    
    private var canvases: [Canvas] = []
    private var canvasTextures: [String: MTLTexture] = [:]
    private let device: MTLDevice
    private let pipelineState: MTLRenderPipelineState
    private let depthState: MTLDepthStencilState
    private let vertexBuffer: MTLBuffer
    //private let indexBuffer: MTLBuffer
    private let commandQueue: MTLCommandQueue
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CanvasRenderer")
    private let samplerState: MTLSamplerState
    
    public init(device: MTLDevice,
                colorFormat: MTLPixelFormat,
                depthFormat: MTLPixelFormat,
                sampleCount: Int) throws {
        self.device = device
        
        // Create Command Queue
        guard let queue = device.makeCommandQueue() else {
            throw NSError(domain: "CanvasRenderer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create command queue."])
        }
        self.commandQueue = queue
        
        // Build Render Pipeline with Blending Enabled
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "canvasVertexShader")!
        let fragmentFunction = library.makeFunction(name: "canvasFragmentShader")!
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "Canvas Render Pipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorFormat
        pipelineDescriptor.depthAttachmentPixelFormat = depthFormat
        
        pipelineDescriptor.vertexDescriptor = Self.makeVertexDescriptor()
        
        // Enable Blending for Transparency
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true  // changed to false
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one // .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one // .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        // Create Pipeline State
        self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        // Depth Stencil State (if needed)
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .always // .less  // Something wrong with the depth of splat renderer!
        depthDescriptor.isDepthWriteEnabled = false // Disable depth writing for transparent objects
        self.depthState = device.makeDepthStencilState(descriptor: depthDescriptor)!
        
        // Create Vertex Buffer for a Quad (Plane)
        let vertices: [Float] = [
            // Positions        // Texture Coordinates
            -0.5,  0.5, 0.0,     1.0, 0.0, // Top-left
             0.5,  0.5, 0.0,     0.0, 0.0, // Top-right
            -0.5, -0.5, 0.0,     1.0, 1.0, // Bottom-left
             0.5, -0.5, 0.0,     0.0, 1.0  // Bottom-right
        ]
        self.vertexBuffer = device.makeBuffer(bytes: vertices,
                                             length: vertices.count * MemoryLayout<Float>.size,
                                             options: [])!
        /*
        let indices: [UInt16] = [
            0, 2, 1, // First triangle
            1, 2, 3  // Second triangle
        ]
        self.indexBuffer = device.makeBuffer(bytes: indices,
                                            length: indices.count * MemoryLayout<UInt16>.size,
                                            options: [])!
        */
        
        // Create Sampler State
                let samplerDescriptor = MTLSamplerDescriptor()
                samplerDescriptor.minFilter = .linear
                samplerDescriptor.magFilter = .linear
                samplerDescriptor.mipFilter = .linear
                samplerDescriptor.sAddressMode = .clampToEdge
                samplerDescriptor.tAddressMode = .clampToEdge

                guard let samplerState = device.makeSamplerState(descriptor: samplerDescriptor) else {
                    throw NSError(domain: "CanvasRenderer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create sampler state."])
                }
                self.samplerState = samplerState
    }
    
    public func render(viewports: [ModelRendererViewportDescriptor],
                       colorTexture: MTLTexture,
                       colorStoreAction: MTLStoreAction,
                       depthTexture: MTLTexture?,
                       rasterizationRateMap: MTLRasterizationRateMap?,
                       renderTargetArrayLength: Int,
                       to commandBuffer: MTLCommandBuffer) throws {
        
        guard let viewport = viewports.first else { return }
        
        // Create Render Pass Descriptor
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = colorTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .load // Do not clear to maintain background
        renderPassDescriptor.colorAttachments[0].storeAction = colorStoreAction
        //renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0) // Transparent
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
        
        if let depthTexture = depthTexture {
            renderPassDescriptor.depthAttachment.texture = depthTexture
            renderPassDescriptor.depthAttachment.loadAction = .load
            renderPassDescriptor.depthAttachment.storeAction = .store
            renderPassDescriptor.depthAttachment.clearDepth = 1.0
        }
        
        renderPassDescriptor.rasterizationRateMap = rasterizationRateMap
        renderPassDescriptor.renderTargetArrayLength = renderTargetArrayLength
        
        // Create Render Encoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            throw NSError(domain: "CanvasRenderer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create render encoder."])
        }
        renderEncoder.label = "Canvas Render Encoder"
        
        // Set Pipeline and Depth State
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        
        
        
        // Set Vertex Buffer
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        // Index Buffer
        //renderEncoder.(indexBuffer, offset: 0, index: 0)  // Do indexbuffer and culling later
        // Back face culling
        //renderEncoder.setCullMode(.back)
        
        // Set Fragment Sampler
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        // Iterate Over All Planes and Render Them
        for canvas in canvases {
            // Calculate Model Matrix
            let translationMatrix = matrix4x4_translation(canvas.position.x, canvas.position.y, canvas.position.z)
            let rotationMatrix = matrix4x4_quaternion(canvas.orientation)
            let scaleMatrix = matrix4x4_scale(canvas.width, canvas.height, 1.0)
            let modelMatrix = translationMatrix * rotationMatrix * scaleMatrix
            
            // Pass Model-View-Projection (MVP) Matrix to Vertex Shader
            var mvpMatrix = viewport.projectionMatrix * viewport.viewMatrix * modelMatrix
            renderEncoder.setVertexBytes(&mvpMatrix, length: MemoryLayout<matrix_float4x4>.stride, index: 1)
            //print("render")
            // print(canvasTextures.count)
            // Set Fragment Texture
            renderEncoder.setFragmentTexture(canvasTextures[canvas.name], index: 0)
            
            // Draw Quad
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        }
        
        // End Encoding
        renderEncoder.endEncoding()
    }
    
    // Methods to add and remove canvases
    public func addCanvas(canvas: Canvas, texture: MTLTexture) {
        canvasTextures[canvas.name] = texture
        print("Texture Added")
        canvases.append(canvas)
        print("Canvas Added")
    }
    public func removeCanvas(name: String) {
        canvases.removeAll { $0.name == name }
        canvasTextures.removeValue(forKey: name)
    }
    /*
    public func addPlane(position: SIMD3<Float>,
                         orientation: simd_quatf,
                         width: Float,
                         height: Float,
                         texture: MTLTexture) {
        let plane = Canvas(position: position,
                          orientation: orientation,
                          width: width,
                          height: height,
                          texture: texture)
        planes.append(plane)
    }
    
    public func removePlane(at index: Int) {
        guard index >= 0 && index < planes.count else {
            log.error("Attempted to remove plane at invalid index \(index).")
            return
        }
        planes.remove(at: index)
    }
     */
    
    private class func makeVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        
        // Position Attribute
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        // Texture Coordinate Attribute
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 3 // After position
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        // Layout
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 5 // 3 for position + 2 for texcoords
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        
        return vertexDescriptor
    }
    
    private func matrix4x4_translation(_ x: Float, _ y: Float, _ z: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.3 = SIMD4<Float>(x, y, z, 1)
        return matrix
    }
    
    private func matrix4x4_scale(_ sx: Float, _ sy: Float, _ sz: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.0.x = sx
        matrix.columns.1.y = sy
        matrix.columns.2.z = sz
        return matrix
    }
    
    private func matrix4x4_quaternion(_ quat: simd_quatf) -> simd_float4x4 {
        return simd_matrix4x4(quat)
    }
}
