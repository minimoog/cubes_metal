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

class ViewController: UIViewController, MTKViewDelegate {
    
    var commandQueue: MTLCommandQueue? = nil
    
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
        
        let vertexBuffer = mtkView.device?.makeBuffer(bytes: cubeVertices, length: cubeVertices.count * MemoryLayout<PosColorVertex>.stride, options: [])
        let vertexMtx = mtkView.device?.makeBuffer(length: MemoryLayout<float4x4>.stride, options: [])
    }

    func loadShader(shader: String) -> MTLRenderPipelineState? {
        guard let library = try? mtkView.device?.makeLibrary(source: shader, options: nil) else { return nil }
        
        let vertexShader = library.makeFunction(name: "vertexShader")
        let fragmentShader = library.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexShader
        pipelineDescriptor.fragmentFunction = fragmentShader
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        let renderPipelineState = try? mtkView.device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        return renderPipelineState
     }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor)
        renderEncoder?.setViewport(MTLViewport(originX: 0.0,
                                               originY: 0.0,
                                               width: Double(view.drawableSize.width),
                                               height: Double(view.drawableSize.height),
                                               znear: -1.0, zfar: 1.0))
        //renderEncoder?.setRenderPipelineState(pipelinestate)
        //renderEncoder?.setVertexBuffer
        //renderEncoder?.drawPrimitives
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

