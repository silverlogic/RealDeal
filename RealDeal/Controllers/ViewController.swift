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
    fileprivate var requestLock = false
    fileprivate var checkingFrame: ARFrame?
    fileprivate var timer = Timer()
    fileprivate var offers = [Offer]()
    fileprivate var showedMerchants: [OffersMerchants] = []
    
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
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.add(.dealfree, position: SCNVector3(-1, 0, -3.8))
//            self.add(.deal10, position: SCNVector3(0, 0, -4))
//            self.add(.deal20, position: SCNVector3(1, 0, -3.8))
//            self.add(.deal30, position: SCNVector3(3, 0, -3))
//            self.add(.deal40, position: SCNVector3(5, 0, 0))
//        }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let results: [SCNHitTestResult] = sceneView.hitTest(touches.first!.location(in: sceneView), options: hitTestOptions)
        for result in results {
            var node = result.node
            var object1: VirtualObject?
            while node.parent != nil {
                if let parent = node.parent as? VirtualObject {
                    object1 = parent
                    break
                }
                node = node.parent!
            }
            guard let object = object1 else { continue }
            let wrapperNode = VirtualObject.convert(object)
            DispatchQueue.main.async {
                object.removeFromParentNode()
                self.setNewVirtualObjectPosition(object.position, wrapperNode)
                self.mainNode.addChildNode(wrapperNode)
            }
        }
    }
}


// MARK: - ARSessionDelegate
extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if requestLock { return }
        requestLock = true
        session.delegate = nil
        // Perform image transformation on separate thread
        DispatchQueue.global(qos: .background).async {
            //let transform = frame.displayTransform(withViewportSize: CGSize(width: 1000, height: 1333), orientation: .portrait)
            let ciImage = CIImage(cvImageBuffer: frame.capturedImage)
            //let transformImage = ciImage.applying(transform)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                print("Can't get CGImage")
                self.requestLock = false
                session.delegate = self
                return
            }
            let image = UIImage(cgImage: cgImage)
            // Send out request and cache the image
            let networkClient = NetworkClient()
            networkClient.postMerchantIcon(image, success: { (merchants) in
                for merchant in merchants {
                    print(merchant.name)
                    guard let offerMerchant = OffersMerchants(rawValue: merchant.name) else { continue }
                    if self.showedMerchants.contains(offerMerchant) {
                        continue
                    }
                    self.showedMerchants.append(offerMerchant)
                    let offers = OffersManager.shared.offersForMerchant(merchant.name)
                    if self.offers.contains(where: { $0.merchants.contains(merchant.name) }) {
                        // Don't do anything since we already check this merchant
                        continue
                    }
                    self.offers.append(contentsOf: offers)
                    // Need to add popup to merchant
                    let angles = frame.camera.eulerAngles
                    let position = SCNVector3.positionFromTransform(frame.camera.transform)
                    let defaultDistance: Float = 2
                    let z1 = position.z - sin(angles.y + Float.pi/2) * defaultDistance
                    let x1 = position.x + cos(angles.y + Float.pi/2) * defaultDistance
                    DispatchQueue.main.async {
                        switch offerMerchant {
                        case .walmart:
                            self.add(.dealfree, position: SCNVector3(x1, -0.3, z1))
                        case .bath:
                            self.add(.deal30, position: SCNVector3(x1, -0.3, z1))
                        case .target:
                            self.add(.deal10, position: SCNVector3(x1, -0.3, z1))
                        }
                    }
                }
                self.requestLock = false
                session.delegate = self
            }, failure: { (error) in
                print("Error checking merchant icon")
                self.requestLock = false
                session.delegate = self
            })
        }
    }
}


// MARK: - Private Instance Methods
fileprivate extension ViewController {
    
    /// Adds SCNNode to the current scene.
    func add(_ deal: Deals, position: SCNVector3) {
        DispatchQueue.global().async {
            let wrapperNode = VirtualObject(deal)
            DispatchQueue.main.async {
                self.setNewVirtualObjectPosition(position, wrapperNode)
                self.mainNode.addChildNode(wrapperNode)
            }
        }
    }
    
    func setupSceneView() {
        sceneView.session = session
        sceneView.delegate = self
        sceneView.session.delegate = self
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

enum OffersMerchants: String {
    case walmart = "Walmart"
    case bath = "Bath and Body Works"
    case target = "Target"
}

