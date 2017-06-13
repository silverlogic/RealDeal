//
//  VirtualObject.swift
//  RealDeal
//
//  Created by Vasilii Muravev on 6/11/17.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import ARKit

class VirtualObject: SCNNode {
    
    let smallOne: Bool
    let deal: Deals
    
    init(_ deal: Deals) {
        self.deal = deal
        switch deal {
        case .deal10, .deal20, .deal30, .deal40, .dealfree:
            smallOne = true
        default:
            smallOne = false
        }
        super.init()
        let scene = SCNScene(named: "art.scnassets/" + deal.rawValue)!
        for child in scene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            child.movabilityHint = .movable
            addChildNode(child)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func convert(_ object: VirtualObject) -> VirtualObject {
        return VirtualObject(object.deal.nextOne())
    }
}

enum Deals: String {
    case dealfree = "dealfree.scn"
    case deal10 = "deal10.scn"
    case deal20 = "deal20.scn"
    case deal30 = "deal30.scn"
    case deal40 = "deal40.scn"
    case dealfreeL = "dealfreeL.scn"
    case deal10L = "deal10L.scn"
    case deal20L = "deal20L.scn"
    case deal30L = "deal30L.scn"
    case deal40L = "deal40L.scn"
    case atmarrow = "atmarrow.scn"
    
    func nextOne() -> Deals {
        switch self {
        case .deal10:
            return .deal10L
        case .deal20:
            return .deal20L
        case .deal30:
            return .deal30L
        case .deal40:
            return .deal40L
        case .dealfree:
            return .dealfreeL
        case .deal10L:
            return .deal10
        case .deal20L:
            return .deal20
        case .deal30L:
            return .deal30
        case .deal40L:
            return .deal40
        case .dealfreeL:
            return .dealfree
        case .atmarrow:
            return self
        }
    }
}
