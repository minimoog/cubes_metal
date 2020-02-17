//
//  cubes_shader.metal
//  01_cubes_metal
//
//  Created by Antonie Jovanoski on 2/17/20.
//  Copyright © 2020 Antonie Jovanoski. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct PosColorVertex {
    float3 xyz;
    uint32_t abgr;
};

struct FragmentData {
    float4 position [[position]];
    float4 color;
};

vertex FragmentData vertexShader(uint vertexID [[vertex_id]],
                                 constant PosColorVertex *vertices [[buffer(0)]],
                                 constant float4x4& modelViewProjMatrix [[buffer(1)]])
{
    FragmentData output;
    
    output.position = modelViewProjMatrix * float4(vertices[vertexID].xyz, 1.0f);
    output.color = float4(vertices[vertexID].abgr & 0xFF,
                          vertices[vertexID].abgr >> 8 & 0xFF,
                          vertices[vertexID].abgr >> 16 & 0xFF,
                          vertices[vertexID].abgr >> 24 & 0xFF);
    
    return output;
}

fragment float4 fragmentShader(FragmentData in [[stage_in]])
{
    return in.color;
}
