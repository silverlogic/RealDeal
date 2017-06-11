//
//  Merchant.swift
//  RealDeal
//
//  Created by Emanuel  Guerrero on 6/10/17.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import UIKit

struct Merchant {
    
    // MARK: - Public Attributes
    let name: String
    let vertices: [CGPoint]
    
    
    // MARK: Initializers
    init(name: String, vertices: [CGPoint]) {
        self.name = name
        self.vertices = vertices
    }
}
