//
//  LogoPartsView.swift
//  RealDeal
//
//  Created by Vasilii Muravev on 6/10/17.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import UIKit
import CoreGraphics

class LogoPartsView: UIView {
    
    // MARK: - Privat Instance Attributes
    fileprivate let logoPart_br = UIImageView(image: #imageLiteral(resourceName: "logoparts-br"))
    fileprivate let logoPart_bl = UIImageView(image: #imageLiteral(resourceName: "logoparts-bl"))
    fileprivate let logoPart_tr = UIImageView(image: #imageLiteral(resourceName: "logoparts-tr"))
    fileprivate let logoPart_tl = UIImageView(image: #imageLiteral(resourceName: "logoparts-tl"))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}


// MARK: - Public Instance Methods
extension LogoPartsView {
    func open(completion: ((_ success: Bool) -> Void)?) {
        UIView.animate(withDuration: 1.5, animations: {
            self.revertLogo(self.logoPart_tl, xAxis: true, yAxis: true)
            self.revertLogo(self.logoPart_tr, xAxis: false, yAxis: true)
            self.revertLogo(self.logoPart_bl, xAxis: true, yAxis: false)
            self.revertLogo(self.logoPart_br, xAxis: false, yAxis: false)
        }, completion: { (success) in
            completion?(success)
        })
    }
}


// MARK: - Private Instance Methods
fileprivate extension LogoPartsView {
    func setup() {
        logoPart_br.frame = self.bounds
        logoPart_bl.frame = self.bounds
        logoPart_tr.frame = self.bounds
        logoPart_tl.frame = self.bounds
        addSubview(logoPart_br)
        addSubview(logoPart_bl)
        addSubview(logoPart_tr)
        addSubview(logoPart_tl)
    }
    
    func revertLogo(_ imageView: UIImageView, xAxis: Bool, yAxis: Bool) {
        imageView.frame = CGRect(
            x: imageView.frame.width * 1.5 * CGFloat(xAxis ? -1.0 : 1.0),
            y: imageView.frame.height * 1.5 * CGFloat(yAxis ? -1.0 : 1.0),
            width: imageView.frame.width,
            height: imageView.frame.height
        )
        imageView.transform = imageView.transform.rotated(by: CGFloat.pi)
    }
}
