//
//  math_util.swift
//  01_cubes_metal
//
//  Created by Antonie Jovanoski on 2/18/20.
//  Copyright © 2020 Antonie Jovanoski. All rights reserved.
//

import Foundation
import simd

public func matrixLookAt(eye: simd_float3, at: simd_float3, up: simd_float3) -> float4x4 {
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

internal func mtxProjXYWH(x: Float, y: Float, width: Float, height: Float, near: Float, far: Float) -> float4x4 {
    let diff = far - near
    let aa = (far + near) / diff
    let bb = (2.0 * far * near) / diff
    
    var result: float4x4 = float4x4()
    
    result[0][0] = width
    result[1][1] = height
    result[2][0] = x
    result[2][1] = y
    result[2][2] = -aa
    result[2][3] = -1.0
    result[3][2] = -bb
    
    return result
}

internal func toRad(deg: Float) -> Float {
    deg * .pi / 180.0
}

public func mtxProj(fovy: Float, aspect: Float, near: Float, far: Float) -> float4x4 {
    let height = 1.0 / tan(toRad(deg: fovy) * 0.5)
    let width = height * 1.0 / aspect
    
    return mtxProjXYWH(x: 0.0, y: 0.0, width: width, height: height, near: near, far: far)
}
