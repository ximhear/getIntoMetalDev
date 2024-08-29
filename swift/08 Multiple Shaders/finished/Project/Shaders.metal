//
//  Shaders.metal
//  HelloTriangle
//
//  Created by Andrew Mengede on 27/2/2022.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

float3 applyDirectionalLight(float3 normal, DirectionalLight light, float3 baseColor, float3 fragCam);
float3 applySpotLight(float3 position, float3 normal, Spotlight light, float3 baseColor, float3 fragCam);
float3 applyPointLight(float3 position, float3 normal, Pointlight light, float3 baseColor, float3 fragCam);

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float2 texCoord [[ attribute(1) ]];
    float3 normal [[ attribute(2) ]];
};

struct Fragment {
    float4 position [[position]];
    float2 texCoord;
    float3 cameraPosition;
    float3 normal;
    float3 normalInV;
    float3 fragmentPosition;
    float3 cameraPositionInV;
    float3 fragmentPositionInV;
};

vertex Fragment vertexShader(
        const VertexIn vertex_in [[ stage_in ]],
        constant matrix_float4x4 &model [[ buffer(1) ]],
        constant CameraParameters &camera [[ buffer(2) ]])
{
    
    matrix_float3x3 diminished_model;
    diminished_model[0][0] = model[0][0];
    diminished_model[0][1] = model[0][1];
    diminished_model[0][2] = model[0][2];
    diminished_model[1][0] = model[1][0];
    diminished_model[1][1] = model[1][1];
    diminished_model[1][2] = model[1][2];
    diminished_model[2][0] = model[2][0];
    diminished_model[2][1] = model[2][1];
    diminished_model[2][2] = model[2][2];
    
    matrix_float3x3 diminished_view;
    matrix_float4x4 view = camera.view * model;
    diminished_view[0][0] = view[0][0];
    diminished_view[0][1] = view[0][1];
    diminished_view[0][2] = view[0][2];
    diminished_view[1][0] = view[1][0];
    diminished_view[1][1] = view[1][1];
    diminished_view[1][2] = view[1][2];
    diminished_view[2][0] = view[2][0];
    diminished_view[2][1] = view[2][1];
    diminished_view[2][2] = view[2][2];
    
    Fragment output;
    output.position = camera.projection * camera.view * model * vertex_in.position;
    output.texCoord = vertex_in.texCoord;
    output.normal = diminished_model * vertex_in.normal;
    output.normalInV = diminished_view * vertex_in.normal;
    output.cameraPosition = float3(model * float4(camera.position, 1.0));
    output.cameraPositionInV = camera.position;
    output.fragmentPosition = float3(model * vertex_in.position);
    output.fragmentPositionInV = float3(camera.view * model * vertex_in.position);
    
    return output;
}

fragment float4 fragmentShader(
    Fragment input [[stage_in]],
    texture2d<float> objectTexture [[texture(0)]],
    sampler samplerObject [[sampler(0)]],
    constant DirectionalLight &sun [[ buffer(0) ]],
    constant Spotlight &spotlight [[ buffer(1) ]],
    constant Pointlight *pointLights [[ buffer(2) ]],
    constant FragmentData &fragUBO [[ buffer(3) ]])
{
    float3 baseColor = float3(objectTexture.sample(samplerObject, input.texCoord));
    float alpha = objectTexture.sample(samplerObject, input.texCoord).a;
    
    //directions
    float3 fragCam = normalize(input.cameraPosition - input.fragmentPosition);
    float3 fragCamInV = normalize(input.cameraPositionInV - input.fragmentPositionInV);
    
    //ambient
    float3 color = 0.2 * baseColor;
    
    //sun
    color += applyDirectionalLight(input.normalInV, sun, baseColor, fragCamInV);
    
    //spotlight
    color += applySpotLight(input.fragmentPositionInV, input.normalInV, spotlight, baseColor, fragCamInV);
    
    for (uint i = 0; i < fragUBO.lightCount; ++i) {
        color += applyPointLight(input.fragmentPosition, input.normal, pointLights[i], baseColor, fragCam);
    }
    
    return float4(color, alpha);
}

float3 applyDirectionalLight(float3 normal, DirectionalLight light, float3 baseColor, float3 fragCam) {
    
    float3 result = float3(0.0);
    
    float3 halfVec = normalize(-light.forwards + fragCam);
    
    //diffuse
    float lightAmount = max(0.0, dot(normal, -light.forwards));
    result += lightAmount * baseColor * light.color;
    
    //specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64);
    result += lightAmount * baseColor * light.color;
    
    return result;
}

float3 applySpotLight(float3 position, float3 normal, Spotlight light, float3 baseColor, float3 fragCam) {
    
    float3 result = float3(0.0);
    
    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCam);
    
    //diffuse
    float lightAmount = max(0.0, dot(normal, fragLight)) * pow(max(0.0, dot(fragLight, light.forwards)),16);
    result += lightAmount * baseColor * light.color;
    
    //specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64) * pow(max(0.0, dot(fragLight, light.forwards)),16);
    result += lightAmount * baseColor * light.color;
    
    return result;
}



float3 applyPointLight(float3 position, float3 normal, Pointlight light, float3 baseColor, float3 fragCam) {
    
    float3 result = float3(0.0);
    
    //directions
    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCam);
    
    //diffuse
    float lightAmount = max(0.0, dot(normal, fragLight));
    result += lightAmount * baseColor * light.color;
    
    //specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64);
    result += lightAmount * baseColor * light.color;
    
    return result;
}
