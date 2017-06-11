//
//  OffersManager.swift
//  RealDeal
//
//  Created by Emanuel  Guerrero on 6/11/17.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation

final class OffersManager {
    
    // MARK: - Shared Instance
    static let shared = OffersManager()
    
    
    // MARK: - Private Instance Attributes
    private var offers = [Offer]()
    
    
    // MARK: - Initializers
    private init() {}
    
    
    // MARK: - Public Instance Methods
    func loadAllOffers() {
        DispatchQueue.global(qos: .userInitiated).async {
            let networkClient = NetworkClient()
            networkClient.retrieveOffers(success: { (offers) in
                self.offers = offers
                print("All offers retrieved")
            }, failure: { (error) in
                print("Error retrieving offers!")
            })
        }
    }
    
    func offersForMerchant(_ merchant: String) -> [Offer] {
        return offers.filter({ $0.merchants.contains(merchant) })
    }
}
