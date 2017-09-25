//
//  CreateAndManageNodes.swift
//  Teaching
//
//  Created by Jordan Campbell on 25/09/17.
//  Copyright © 2017 Jordan Campbell. All rights reserved.
//
//
//
//  COPIED AND MODIFIED FROM https://github.com/exyte/ARTetris/blob/master/ARTetris/TetrisScene.swift

import Foundation
import SceneKit

/*
 Default behaviour:
     - add 9 magenta cubes in a 3x3 grid, all evenly spaced.
     - cubes are added in a vertical plane, i.e they all have the same depth
 */

class CreateAndManageNodes {
    
    private let numCubes = 9
    private let cubeSpacing: Float = 0.2    // spacing between each of the cubes in metres.
    private let cubeSize: Float = 0.05
    
    private let scene: SCNScene
    private let x: Float
    private let y: Float
    private let z: Float
    
    // perform initialisation given current scene and root anchor position
    init(_ scene: SCNScene, _ x: Float, _ y: Float, _ z: Float) {
        self.scene = scene
        self.x = x
        self.y = y
        self.z = z
        
        // let defaultCube = createCube(0, 0)
        // self.scene.rootNode.addChildNode(defaultCube)
        
        createGrid()
    }
    
    func createGrid() {
        
        // this is hardcoded at the moment but should ideally use self.numCubes to construct the arrays
        let idx: [Float] = [-1, 0, 1]
        let kdx: [Float] = [-1, 0, 1]
        
        for i in idx {
            for k in kdx {
               
                let x = i * cubeSpacing
                let y = k * cubeSpacing
                
                let cube = createCube(x, y)
                self.scene.rootNode.addChildNode(cube)
            }
        }
        
    }
    
    func createCube(_ x: Float, _ y: Float) -> SCNNode {
        
        let cubeSize = cg(self.cubeSize)
        let box = SCNBox(width: cubeSize, height: cubeSize, length: cubeSize, chamferRadius: cubeSize / 10)
        let matrix = translate(Float(x), Float(y) - 0.5)
        
        return createNode(box, matrix)
    }
    
    private func translate(_ x: Float, _ y: Float, _ z: Float = 0) -> SCNMatrix4 {
        return SCNMatrix4MakeTranslation(self.x + x * self.cubeSize, self.y + y * self.cubeSize, self.z + z * self.cubeSize)
    }
    
    private func cg(_ f: Float) -> CGFloat { return CGFloat(f) }
    
    // any elements associated with the node, such as labels etc, can be added here.
    private func createNode(_ geometry: SCNGeometry, _ matrix: SCNMatrix4) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(named: "magenta")
        geometry.firstMaterial = material
        let node = SCNNode(geometry: geometry)
        node.transform = matrix
        return node
    }
}

extension SCNMatrix4 {
    func scale(_ s: Float) -> SCNMatrix4 { return SCNMatrix4Scale(self, s, s, s) }
}
