//
//  Offer.swift
//  RealDeal
//
//  Created by Emanuel  Guerrero on 6/11/17.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation

struct Offer {
    
    // MARK: - Public Instance Attributes
    let title: String
    let description: String
    let descriptionCopy: String
    let merchants: [String]
    
    
    // MARK: - Initializers
    init(title: String, description: String, descriptionCopy: String, merchants: [String]) {
        self.title = title
        self.description = description
        self.descriptionCopy = descriptionCopy
        self.merchants = merchants
    }
}
