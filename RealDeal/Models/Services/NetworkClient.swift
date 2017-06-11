//
//  NetworkClient.swift
//  RealDeal
//
//  Created by Emanuel  Guerrero on 6/10/17.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

final class NetworkClient {
    
    // MARK: - Public Instance Methods
    func postMerchantIcon(_ image: UIImage, success: @escaping (_ merchants: [Merchant]) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        let imageData = UIImageJPEGRepresentation(image, 0.7)
        let baseEncodedString = imageData?.base64EncodedString()
        let request = ["image": ["content": baseEncodedString], "features": ["type": "LOGO_DETECTION"]]
        let requests = ["requests": [request]]
        Alamofire.request("https://vision.googleapis.com/v1/images:annotate?key=AIzaSyD2r9XCsPRouIxWYkdPyPDclHYYsh5CNwE", method: .post, parameters: requests, encoding: JSONEncoding())
        .validate()
        .responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let logoAnnotations = json["responses"][0].arrayValue
                var merchants = [Merchant]()
                for subJson in logoAnnotations {
                    let name = subJson["description"].stringValue
                    let vertices = subJson["boundingPoly"]["vertices"].arrayValue
                    var points = [CGPoint]()
                    for vertice in vertices {
                        let x = vertice["x"].doubleValue
                        let y = vertice["y"].doubleValue
                        points.append(CGPoint(x: x, y: y))
                    }
                    merchants.append(Merchant(name: name, vertices: points))
                }
                success(merchants)
                break
            case .failure(let error):
                print(error)
                failure(error)
                break
            }
        }
    }
    
    func retrieveOffers(success: @escaping (_ offers: [Offer]) -> Void, failure: @escaping (_ error: Error) -> Void) {
        Alamofire.request("http://real-deal.tsl.io/api/offers", method: .get)
        .validate()
        .responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let offersArray = json.arrayValue
                var offers = [Offer]()
                for subJson in offersArray {
                    let title = subJson["title"].stringValue
                    let description = subJson["short_description"].stringValue
                    let descriptionCopy = subJson["copy"].stringValue
                    let merchantsArray = subJson["merchants"].arrayValue
                    var merchants = [String]()
                    for merchant in merchantsArray {
                        merchants.append(merchant["name"].stringValue)
                    }
                    offers.append(Offer(title: title, description: description, descriptionCopy: descriptionCopy, merchants: merchants))
                }
                success(offers)
                break
            case .failure(let error):
                print(error)
                failure(error)
                break
            }
        }
    }
}
