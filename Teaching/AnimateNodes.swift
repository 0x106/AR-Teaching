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
    
    // perform initialisation given current scene and root anchor position
    init(_ scene: SCNScene) {
        self.scene = scene
        
        // spin on your own axis
        localSpin()
        
        // spin around a random point
        localSpinOnDistalPivot()
    }
    
    // spin around the axis through the centre of the node
    func localSpin() {
        for node in self.scene.rootNode.childNodes {
            startAnimationLocalAxisSpin(node: node)
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

    func startAnimationLocalAxisSpin(node: SCNNode) {
        let rotation = SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 1)
        node.runAction(SCNAction.repeatForever(rotation)!)
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

