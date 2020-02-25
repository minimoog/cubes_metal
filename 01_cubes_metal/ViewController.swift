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
    let x: Float
    let y: Float
    let z: Float
    let c: UInt32
}

let cubeVertices: [PosColorVertex] = [
    PosColorVertex(x: -1.0, y:  1.0, z:  1.0, c: 0xff000000),
    PosColorVertex(x:  1.0, y:  1.0, z:  1.0, c: 0xff0000ff),
    PosColorVertex(x: -1.0, y: -1.0, z:  1.0, c: 0xff00ff00),
    PosColorVertex(x:  1.0, y: -1.0, z:  1.0, c: 0xff00ffff),
    PosColorVertex(x: -1.0, y:  1.0, z: -1.0, c: 0xffff0000),
    PosColorVertex(x:  1.0, y:  1.0, z: -1.0, c: 0xffff00ff),
    PosColorVertex(x: -1.0, y: -1.0, z: -1.0, c: 0xffffff00),
    PosColorVertex(x:  1.0, y: -1.0, z: -1.0, c: 0xffffffff)
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

class ViewController: UIViewController, MTKViewDelegate {
    
    var commandQueue: MTLCommandQueue? = nil
    //var vertexMtx: MTLBuffer? = nil
    var vertexBuffer: MTLBuffer? = nil
    var indexBuffer: MTLBuffer? = nil
    var pipelineState: MTLRenderPipelineState? = nil
    
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
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
        renderEncoder?.setViewport(MTLViewport(originX: 0.0,
                                               originY: 0.0,
                                               width: Double(view.drawableSize.width),
                                               height: Double(view.drawableSize.height),
                                               znear: -1.0, zfar: 1.0))
        
        let viewMatrix = matrixLookAt(eye: [0.0, 0.0, -35.0], at: [0.0, 0.0, 0.0], up: [0.0, 1.0, 0.0])
        let projMatrix = mtxProj(fovy: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
        var finalMatrix = projMatrix * viewMatrix
        
        renderEncoder?.setVertexBytes(&finalMatrix, length: MemoryLayout<float4x4>.size, index: 1)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setRenderPipelineState(pipelineState!)
        renderEncoder?.drawIndexedPrimitives(type: .triangleStrip, indexCount: cubeTriStrip.count, indexType: .uint16, indexBuffer: indexBuffer!, indexBufferOffset: 0)
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

