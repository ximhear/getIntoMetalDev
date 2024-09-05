//
//  postShaders.metal
//  Project
//
//  Created by Andrew Mengede on 14/4/2023.
//

#include <metal_stdlib>
using namespace metal;
#include "definitions.h"

struct FragmentPost {
    float4 position [[position]];
    float2 texCoord;
};

vertex FragmentPost vertexShaderPost (
        const device SimpleVertex *vertices [[ buffer(0) ]],
        unsigned int vid [[vertex_id]])
{
    
    FragmentPost output;
    SimpleVertex vertex_in = vertices[vid];
    output.position = float4(vertex_in.position, 0, 1);
    output.texCoord = 0.5 * (float2(1.0) + vertex_in.position);
    output.texCoord.y *= -1;
//    output.texCoord.x = 0.5 * (1.0 + vertex_in.position.x);
//    output.texCoord.y = 1 - 0.5 * (1.0 + vertex_in.position.y);

    return output;
}

fragment float4 fragmentShaderPost (
    FragmentPost input [[stage_in]],
    texture2d<float> screenTexture [[texture(0)]],
    sampler screenSampler [[sampler(0)]])
{
    float3 baseColor = float3(screenTexture.sample(screenSampler, input.texCoord));
    float average = (baseColor.r + baseColor.g + baseColor.b) / 3;
    
    return float4(float3(average), 1.0);
}
