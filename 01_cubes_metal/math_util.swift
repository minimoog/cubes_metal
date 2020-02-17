//
//  math_util.swift
//  01_cubes_metal
//
//  Created by Antonie Jovanoski on 2/18/20.
//  Copyright © 2020 Antonie Jovanoski. All rights reserved.
//

import Foundation
import simd

func matrixLookAt(eye: simd_float3, at: simd_float3, up: simd_float3) -> float4x4 {
    let view: simd_float3 = normalize(eye - at)
    let uxv = cross(up, view)
    let right = normalize(uxv)
    let up = cross(view, right)
    
    var output: float4x4 = float4x4()
    
    output[0] = simd_float4(right.x, up.x, view.x, 0.0)
    output[1] = simd_float4(right.y, up.y, view.y, 0.0)
    output[2] = simd_float4(right.x, up.z, view.z, 0.0)
    output[3] = simd_float4(-dot(right, eye),
                            -dot(up, eye),
                            -dot(view, eye),
                            1.0)
    
    return output
}

