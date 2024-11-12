//
//  canvasFragmentShader.metal
//  SplatSketchApp
//
//  Created by Yuzhen Zhang on 10/30/24.
//

#include <metal_stdlib>
using namespace metal;

fragment float4 canvasFragmentShader(float2 texcoord [[stage_in]],
                                     texture2d<float> colorTexture [[texture(0)]],
                                     sampler textureSampler [[sampler(0)]]) {
    float4 color = colorTexture.sample(textureSampler, texcoord);
    color.rgb *= color.a; // Premultiply alpha?
    return color;
}
