//
//  ViewController.swift
//  MetalSample
//
//  Created by 山口智生 on 2015/11/05.
//  Copyright © 2015年 Tomoki Yamaguchi. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {
    
    var device: MTLDevice! = nil
    
    var metalLayer: CAMetalLayer! = nil
    
    let vertexData:[Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0]
    
    var vertexBuffer: MTLBuffer! = nil
    
    var pipelineState: MTLRenderPipelineState! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    
    var timer: CADisplayLink! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()          // 1
        metalLayer.device = device           // 2
        metalLayer.pixelFormat = .BGRA8Unorm // 3
        metalLayer.framebufferOnly = true    // 4
        metalLayer.frame = view.layer.frame  // 5
        view.layer.addSublayer(metalLayer)   // 6
        
        let dataSize = vertexData.count * sizeofValue(vertexData[0]) // 1
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: MTLResourceOptions.OptionCPUCacheModeDefault) // 2
        
        // 1
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.newFunctionWithName("basic_fragment")
        let vertexProgram = defaultLibrary!.newFunctionWithName("basic_vertex")
        
        // 2
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        // 3
        pipelineState = try! device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        
        
        commandQueue = device.newCommandQueue()
        
        
        timer = CADisplayLink(target: self, selector: Selector("gameloop"))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
    }
    
    func render() {
        let drawable = metalLayer.nextDrawable()
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable!.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.commandBuffer()
        let renderEncoderOpt = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        
        renderEncoderOpt.setRenderPipelineState(pipelineState)
        renderEncoderOpt.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        renderEncoderOpt.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoderOpt.endEncoding()
        
        
        commandBuffer.presentDrawable(drawable!)
        commandBuffer.commit()
    }
    
    func gameloop() {
        autoreleasepool {
            self.render()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

