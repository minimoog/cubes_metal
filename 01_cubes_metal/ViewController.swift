//
//  ViewController.swift
//  01_cubes_metal
//
//  Created by Antonie Jovanoski on 2/17/20.
//  Copyright © 2020 Antonie Jovanoski. All rights reserved.
//

import UIKit
import MetalKit
import simd

struct PosColorVertex {
    let xyz: simd_float3
    let c: simd_uchar4
}

let cubeVertices: [PosColorVertex] = [
    PosColorVertex(xyz: simd_float3([-1.0, 1.0, 1.0]), c: simd_uchar4(0xff, 0x00, 0x00, 0x00)),
    PosColorVertex(xyz: simd_float3([ 1.0, 1.0, 1.0]), c: simd_uchar4(0xff, 0x00, 0x00, 0xff)),
    PosColorVertex(xyz: simd_float3([-1.0,-1.0, 1.0]), c: simd_uchar4(0xff, 0x00, 0xff, 0x00)),
    PosColorVertex(xyz: simd_float3([ 1.0,-1.0, 1.0]), c: simd_uchar4(0xff, 0x00, 0xff, 0xff)),
    PosColorVertex(xyz: simd_float3([-1.0, 1.0,-1.0]), c: simd_uchar4(0xff, 0xff, 0x00, 0x00)),
    PosColorVertex(xyz: simd_float3([ 1.0, 1.0,-1.0]), c: simd_uchar4(0xff, 0xff, 0x00, 0xff)),
    PosColorVertex(xyz: simd_float3([-1.0,-1.0,-1.0]), c: simd_uchar4(0xff, 0xff, 0xff, 0x00)),
    PosColorVertex(xyz: simd_float3([ 1.0,-1.0,-1.0]), c: simd_uchar4(0xff, 0x00, 0x00, 0xff))
]

let cubeTriStrip: [Int16] =
[
    0, 1, 2,
    3,
    7,
    1,
    5,
    0,
    4,
    2,
    6,
    7,
    4,
    5,
];

let triList: [Int16] =
[
    0, 1, 2, // 0
    1, 3, 2,
    4, 6, 5, // 2
    5, 6, 7,
    0, 2, 4, // 4
    4, 2, 6,
    1, 5, 3, // 6
    5, 7, 3,
    0, 4, 1, // 8
    4, 5, 1,
    2, 3, 6, // 10
    6, 3, 7,
]

class ViewController: UIViewController, MTKViewDelegate {
    
    var commandQueue: MTLCommandQueue? = nil
    //var vertexMtx: MTLBuffer? = nil
    var vertexBuffer: MTLBuffer? = nil
    var indexBuffer: MTLBuffer? = nil
    var pipelineState: MTLRenderPipelineState? = nil
    var startTime: Double = CACurrentMediaTime()
    
    @IBOutlet weak var mtkView: MTKView! {
        didSet {
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
            mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mtkView.device = MTLCreateSystemDefaultDevice()
        commandQueue = mtkView.device?.makeCommandQueue()
        
        vertexBuffer = mtkView.device?.makeBuffer(bytes: cubeVertices, length: cubeVertices.count * MemoryLayout<PosColorVertex>.stride, options: [])
        indexBuffer = mtkView.device?.makeBuffer(bytes: cubeTriStrip, length: cubeTriStrip.count * MemoryLayout<Int16>.stride, options: [])
        
        pipelineState = loadShader()
    }

    func loadShader() -> MTLRenderPipelineState? {
        do {
            let library = try mtkView.device?.makeDefaultLibrary()
            
            let vertexShader = library?.makeFunction(name: "vertexShader")
            let fragmentShader = library?.makeFunction(name: "fragmentShader")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexShader
            pipelineDescriptor.fragmentFunction = fragmentShader
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
            
            let renderPipelineState = try? mtkView.device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
            
            return renderPipelineState
        } catch let error as NSError {
            print(error)
            
            return nil
        }
     }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        let currentTime = CACurrentMediaTime()
        let offsetTime = currentTime - startTime
        
        let width = view.drawableSize.width
        let height = view.drawableSize.height
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
        renderEncoder?.setViewport(MTLViewport(originX: 0.0,
                                               originY: 0.0,
                                               width: Double(width),
                                               height: Double(height),
                                               znear: -1.0, zfar: 1.0))
        
        let viewMatrix = float4x4(eye: [0.0, 0.0, -35.0], at: [0.0, 0.0, 0.0])
        let projMatrix = float4x4(fov: 45.0, aspect: Float(width) / Float(height), near: 0.1, far: 100.0)
        let projViewMatrix = projMatrix * viewMatrix
        
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setRenderPipelineState(pipelineState!)
        renderEncoder?.setCullMode(.back)
        
        for yy in 0..<11 {
            for xx in 0..<11 {
                var modelMatrix = float4x4(rotateX: Float(offsetTime) + Float(xx) * 0.21, rotateY: Float(offsetTime) + Float(yy) * 0.37)
                modelMatrix[3][0] = -15.0 + Float(xx) * 3.0
                modelMatrix[3][1] = -15.0 + Float(yy) * 3.0
                modelMatrix[3][2] = 0.0
                
                var finalMatrix = projViewMatrix * modelMatrix
                
                renderEncoder?.setVertexBytes(&finalMatrix, length: MemoryLayout<float4x4>.size, index: 1)
                renderEncoder?.drawIndexedPrimitives(type: .triangleStrip, indexCount: cubeTriStrip.count, indexType: .uint16, indexBuffer: indexBuffer!, indexBufferOffset: 0)
            }
        }
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

