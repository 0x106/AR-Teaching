//
//  ViewController.swift
//  Teaching
//
//  Created by Jordan Campbell on 25/09/17.
//  Copyright © 2017 Jordan Campbell. All rights reserved.
//
// all line stuff from https://github.com/gao0122/ARKit-Example-by-Apple/blob/master/ARKitExample/UI%20Elements/HitTestVisualization.swift

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let overlayView = LineOverlayView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        overlayView.backgroundColor = UIColor.clear
        overlayView.frame = sceneView.frame
        sceneView.addSubview(overlayView)
        
        // we create the scene here since the gridScene will modify it, but we may want to do other
        // additions / modifications later
        let defaultScene = SCNScene()
        let _ = CreateAndManageNodes(defaultScene, 0, 0, -1)
        let _ = AnimateNodes(defaultScene)

        // Set the scene to the view
        sceneView.scene = defaultScene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // This is the new code added to account for hit tests.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            
            // Touch to 3D Object
            if let hit = sceneView.hitTest(touchLocation, options: nil).first {
                hit.node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
                return
            }

        }
    }
    
}
