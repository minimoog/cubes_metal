//
//  math_util.swift
//  01_cubes_metal
//
//  Created by Antonie Jovanoski on 2/18/20.
//  Copyright © 2020 Antonie Jovanoski. All rights reserved.
//

import Foundation
import simd

extension float4x4 {
    init(fov: Float, aspect: Float, near: Float, far: Float) {
        let yScale = 1 / tan(fov * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let wzScale = -2 * far * near / zRange
        
        let xx = xScale
        let yy = yScale
        let zz = zScale
        let zw = Float(-1)
        let wz = wzScale
        
        self.init(vector4(xx,  0,  0,  0),
                  vector4( 0, yy,  0,  0),
                  vector4( 0,  0, zz, zw),
                  vector4( 0,  0, wz,  0))
    }
}

extension float4x4 {
    init(axis: simd_float3, angle: Float) {
        let a = normalize(axis)
        let x = a.x, y = a.y, z = a.z
        let c = cosf(angle)
        let s = sinf(angle)
        let t = 1 - c
        self.init(simd_float4( t * x * x + c,     t * x * y + z * s, t * x * z - y * s, 0),
                  simd_float4( t * x * y - z * s, t * y * y + c,     t * y * z + x * s, 0),
                  simd_float4( t * x * z + y * s, t * y * z - x * s,     t * z * z + c, 0),
                  simd_float4(                 0,                 0,                 0, 1))
    }
}

extension float4x4 {
    init(eye: simd_float3, at: simd_float3, up: simd_float3 = simd_float3(0, 1, 0)) {
        let view = normalize(eye     - at)
        let uxv = cross(up, view)
        let right = normalize(uxv)
        let up = cross(view, right)
        
        self.init(vector4( right.x,          up.x,          view.x,         0.0),
                  vector4( right.y,          up.y,          view.y,         0.0),
                  vector4( right.z,          up.z,          view.z,         0.0),
                  vector4(-dot(right, eye), -dot(up, eye), -dot(view, eye), 1.0))
    }
}

extension float4x4 {
    init(rotateX: Float, rotateY: Float) {
        let sx = sin(rotateX);
        let cx = cos(rotateX);
        let sy = sin(rotateY);
        let cy = cos(rotateY);

        self.init(vector4( cy,   sx * sy,  -cx * sy,    0),
                  vector4( 0,         cx,        sx,    0),
                  vector4( sy,  -sx * cy,   cx * cy,    0),
                  vector4( 0,          0,         0,  1.0))
    }
}
