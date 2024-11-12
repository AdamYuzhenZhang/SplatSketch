//
//  canvasVertexShader.metal
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/30/24.
//

#include <metal_stdlib>
using namespace metal;

// Structure matching the vertex buffer layout
struct Vertex {
    float3 position [[attribute(0)]];
    float2 texcoord [[attribute(1)]];
};

// Vertex Output
struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
};

// MVP matrix passed from the renderer
struct Uniforms {
    float4x4 mvpMatrix;
};

vertex VertexOut canvasVertexShader(const Vertex inVertex [[stage_in]],
                                    constant Uniforms &uniforms [[buffer(1)]]) {
    VertexOut out;
    float4 pos = float4(inVertex.position, 1.0);
    out.position = uniforms.mvpMatrix * pos;
    out.texcoord = inVertex.texcoord;
    return out;
}
