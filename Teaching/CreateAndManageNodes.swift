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
    private let cubeSpacing: Float = 5   // spacing between each of the cubes
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
        
        // -- if we only want to add a single default cube
        // let defaultCube = createCube(0, 0)
        // self.scene.rootNode.addChildNode(defaultCube)
        
        createGrid()
        createPipes()
    }
    
    func getScene() -> SCNScene {
        return self.scene
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
    
    func createPipes() {
        let _ = createPipe(0, 1)
        let _ = createPipe(0, 3)
        let _ = createPipe(1, 2)
        let _ = createPipe(1, 4)
        let _ = createPipe(2, 5)
        let _ = createPipe(3, 4)
        let _ = createPipe(3, 6)
        let _ = createPipe(4, 5)
        let _ = createPipe(4, 7)
        let _ = createPipe(5, 8)
        let _ = createPipe(6, 7)
        let _ = createPipe(7, 8)
    }
    
    func createCube(_ x: Float, _ y: Float) -> SCNNode {
        let cubeSize = CGFloat(self.cubeSize)
        let box = SCNBox(width: cubeSize, height: cubeSize, length: cubeSize, chamferRadius: cubeSize / 10)
        let matrix = translate(Float(x), Float(y) - 0.5)
        return createNode(box, matrix)
    }
    
    func createPipe(_ x: Int, _ y: Int) {
        let pipe = SCNCylinder(radius: 0.005, height: CGFloat(getDistance(nodeAt(x), nodeAt(y))))
        let matrix = translate(0, 0)
        let node = createNode(pipe, matrix)
        node.transform = lineBetweenPoints(from: nodeAt(x).position, to: nodeAt(y).position)
        self.scene.rootNode.addChildNode(node)
    }
    
    func getDistance(_ n1: SCNNode, _ n2: SCNNode) -> CGFloat {
        let w = SCNVector3(x: n2.position.x-n1.position.x,
                           y: n2.position.y-n1.position.y,
                           z: n2.position.z-n1.position.z)
        let distance = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
        return distance
    }
    
    private func translate(_ x: Float, _ y: Float, _ z: Float = 0) -> SCNMatrix4 {
        return SCNMatrix4MakeTranslation(self.x + x * self.cubeSize, self.y + y * self.cubeSize, self.z + z * self.cubeSize)
    }
    
    // any elements associated with the node, such as labels etc, can be added here.
    private func createNode(_ geometry: SCNGeometry, _ matrix: SCNMatrix4) -> SCNNode {
        geometry.firstMaterial?.diffuse.contents = UIColor.magenta
        geometry.firstMaterial?.transparency = CGFloat(0.5)
        let node = SCNNode(geometry: geometry)
        node.transform = matrix
        node.name = "scenenode"
        return node
    }
    
    // https://stackoverflow.com/a/42941966/7098234
    func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
        let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
        if length == 0 {
            return SCNVector3(0.0, 0.0, 0.0)
        }
        
        return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
        
    }
    
    func nodeAt(_ index: Int) -> SCNNode {
        return self.scene.rootNode.childNodes[index]
    }
    
    // https://stackoverflow.com/a/42941966/7098234
    func lineBetweenPoints(from startPoint: SCNVector3, to endPoint: SCNVector3) -> SCNMatrix4 {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))

        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0,0)
        //target vector, in new coordination
        let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                            (endPoint.z-startPoint.z)/2.0)
        
        // axis between two vector
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
        
        //normalized axis vector
        let av_normalized = normalizeVector(av)
        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        var transform = SCNMatrix4()
        
        transform.m11 = r_m11
        transform.m12 = r_m12
        transform.m13 = r_m13
        transform.m14 = 0.0
        
        transform.m21 = r_m21
        transform.m22 = r_m22
        transform.m23 = r_m23
        transform.m24 = 0.0
        
        transform.m31 = r_m31
        transform.m32 = r_m32
        transform.m33 = r_m33
        transform.m34 = 0.0
        
        transform.m41 = (startPoint.x + endPoint.x) / 2.0
        transform.m42 = (startPoint.y + endPoint.y) / 2.0
        transform.m43 = (startPoint.z + endPoint.z) / 2.0
        transform.m44 = 1.0
        
        return transform
    }
}

extension SCNMatrix4 {
    func scale(_ s: Float) -> SCNMatrix4 { return SCNMatrix4Scale(self, s, s, s) }
}
