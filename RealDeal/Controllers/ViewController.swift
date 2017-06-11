//
//  ViewController.swift
//  RealDeal
//
//  Created by Emanuel  Guerrero on 6/10/17.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    fileprivate let session = ARSession()
    
    fileprivate var mainNode: SCNNode!
    fileprivate weak var logoView: LogoPartsView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        /* Animated logo parts */
        let logoView = LogoPartsView(frame: view.bounds)
        self.logoView = logoView
        view.addSubview(logoView)
        view.bringSubview(toFront: logoView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSession()
        // @TODO: Temporary test deals icons
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.add(.dealfree, position: SCNVector3(-1, 0, -3.8))
            self.add(.deal10, position: SCNVector3(0, 0, -4))
            self.add(.deal20, position: SCNVector3(1, 0, -3.8))
            self.add(.deal30, position: SCNVector3(3, 0, -3))
            self.add(.deal40, position: SCNVector3(5, 0, 0))
        }
        guard let logoView = logoView else { return }
        view.bringSubview(toFront: logoView)
        logoView.open(completion: { [weak logoView] (success) in
            logoView?.removeFromSuperview()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
}


// MARK: - Private Instance Methods
fileprivate extension ViewController {
    
    /// Adds SCNNode to the current scene.
    func add(_ deal: Deals, position: SCNVector3) {
        DispatchQueue.global().async {
            let scene = SCNScene(named: "art.scnassets/" + deal.rawValue)!
            let wrapperNode = SCNNode()
            for child in scene.rootNode.childNodes {
                child.geometry?.firstMaterial?.lightingModel = .physicallyBased
                child.movabilityHint = .movable
                wrapperNode.addChildNode(child)
            }
            DispatchQueue.main.async {
                self.setNewVirtualObjectPosition(position, wrapperNode)
                self.mainNode.addChildNode(wrapperNode)
            }
        }
    }
    
    func setupSceneView() {
        sceneView.session = session
        sceneView.delegate = self
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = false
        sceneView.preferredFramesPerSecond = 60
        sceneView.contentScaleFactor = 1.3
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
//        sceneView.showsStatistics = true
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
        resetMainNode()
    }
    
    func setupSession() {
        let configuration = ARWorldTrackingSessionConfiguration()
//        configuration.planeDetection = .horizontal
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func resetMainNode() {
        defer {
            self.mainNode = SCNNode()
            DispatchQueue.main.async {
                self.setNewVirtualObjectPosition(SCNVector3Zero, self.mainNode)
                self.sceneView.scene.rootNode.addChildNode(self.mainNode)
            }
        }
        guard let mainNode = mainNode else { return }
        for child in mainNode.childNodes {
            child.removeFromParentNode()
        }
        mainNode.removeFromParentNode()
    }
    
    func setNewVirtualObjectPosition(_ pos: SCNVector3, _ object: SCNNode) {
        guard let cameraTransform = session.currentFrame?.camera.transform else {
            object.position = pos
            return
        }
        let cameraWorldPos = SCNVector3.positionFromTransform(cameraTransform)
        var cameraToPosition = pos - cameraWorldPos
        // Limit the distance of the object from the camera to a maximum of 10 meters.
        cameraToPosition.setMaximumLength(10)
        object.position = cameraWorldPos + cameraToPosition
        if cameraToPosition.x == 0 {
            return
        }
        let tgA: Double =  Double(cameraToPosition.z) / Double(cameraToPosition.x)
        let cornerB = Double.pi / 2 - atan(tgA)
        if cameraToPosition.x < 0 {
            object.eulerAngles = SCNVector3(0, cornerB, 0)
        } else {
            object.eulerAngles = SCNVector3(0, Double.pi + cornerB, 0)
        }
    }
}

enum Deals: String {
    case dealfree = "dealfree.scn"
    case deal10 = "deal10.scn"
    case deal20 = "deal20.scn"
    case deal30 = "deal30.scn"
    case deal40 = "deal40.scn"
}
