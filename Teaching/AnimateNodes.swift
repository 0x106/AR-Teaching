//
//  AnimateNodes.swift
//  Teaching
//
//  Created by Jordan Campbell on 1/10/17.
//  Copyright © 2017 Jordan Campbell. All rights reserved.
//

import Foundation
import SceneKit

class AnimateNodes {
    
    private let scene: SCNScene
    private var matches: [[Int]] = []
    
    // perform initialisation given current scene and root anchor position
    init(_ scene: SCNScene) {
        self.scene = scene
        
        self.matches.append([0, 1])
        self.matches.append([0, 3])
        self.matches.append([1, 2])
        self.matches.append([1, 4])
        self.matches.append([2, 5])
        self.matches.append([3, 4])
        self.matches.append([3, 6])
        self.matches.append([4, 5])
        self.matches.append([4, 7])
        self.matches.append([5, 8])
        self.matches.append([6, 7])
        self.matches.append([7, 8])

        // spin on your own axis
        localSpin()
        
        // spin around a random point
        localSpinOnDistalPivot()
        
        // be sure to update the pipes
        let updateCylinders = SCNAction.customAction(duration: 1) { (node, elapsedTime) -> () in
            var pair = 0
            for n in node.childNodes {
                if n.name == "scenenode" && (n.geometry?.isKind(of: SCNCylinder.self))! {
                    n.transform = self.lineBetweenPoints(from: self.nodeAt(self.matches[pair][0]).position, to: self.nodeAt(self.matches[pair][1]).position)
                    
                    if pair == 3 {
                        print(pair, self.matches[pair])
                        print(self.nodeAt(self.matches[pair][0]).position)
                        print(n.transform)
                        print("--------------------")
                    }
                    
                    pair = pair + 1
                }
            }
        }
        self.scene.rootNode.runAction(SCNAction.repeatForever(updateCylinders)!)
    }
    
    // spin around the axis through the centre of the node
    func localSpin() {
        for node in self.scene.rootNode.childNodes {
            if (node.geometry?.isKind(of: SCNBox.self))! {
                startAnimationLocalAxisSpin(node: node)
            }
        }
    }
    
    // spin around the pivot, which is ~not~ in the same place as the centre of the node
    func localSpinOnDistalPivot () {
        
        let matrix = SCNMatrix4MakeTranslation(0.1, 0, 0)
        
        // rotate a single node
        let node = self.scene.rootNode.childNodes[1]
        node.pivot = matrix
        startAnimationLocalAxisSpin(node: node)
        
        // rotate all the nodes
        // for node in self.scene.rootNode.childNodes {
        //    node.pivot = matrix
        //    startAnimationLocalAxisSpin(node: node)
        //}
    
    }
    
    // https://stackoverflow.com/a/42941966/7098234
    func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
        let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
        if length == 0 {
            return SCNVector3(0.0, 0.0, 0.0)
        }
        
        return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
        
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

    func startAnimationLocalAxisSpin(node: SCNNode) {
        let rotation = SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 1)
        node.runAction(SCNAction.repeatForever(rotation)!)
    }
    
    func nodeAt(_ index: Int) -> SCNNode {
        return self.scene.rootNode.childNodes[index]
    }
}




// ------ Miscellaneous code for performing animations ------ //
//        let rotate_fwd = SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: 1)
//        let rotate_bck = SCNAction.rotateBy(x: -1, y: 0, z: 0, duration: 1)
//        let global_rotate = SCNAction.rotateBy(x: 0.5, y: 0, z: 0, duration: 1)
//        let turbulence = SCNAction.sequence([rotate_fwd, rotate_bck])
//        let motion = SCNAction.group([global_rotate, rotate_fwd!])
//        let rotationLoop = SCNAction.repeatForever(turbulence!)
//        node.runAction(rotationLoop!)
//        moveOn(node: node)

