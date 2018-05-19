//
//  UIImageView.swift
//  CoutureLane
//
//  Created by Bernal Yescas, Francisco on 3/29/18.
//  Copyright © 2018 Couture Lane. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func download(url: URL?, indicator: Bool = true, placeholder: UIImage? = nil) {
        guard let url = url else {
            return
        }
        self.kf.indicatorType = indicator ? .activity : .none
        self.kf.setImage(with: url,
                         placeholder: placeholder,
                         options: [.transition(.fade(0.2))])
    }
    
    func loadProductImage (fromFilename fileName: String?) {
        if let fileName = fileName {
            self.download(url: URL(string: "\(AppAttributes.CoutureLaneURL)/product-images-thumb/\(fileName)"),
                          indicator: true,
                          placeholder: nil)
        }
    }

    func loadMerchantImage (fromFilename fileName: String?) {
        if let fileName = fileName {
            self.download(url: URL(string: "\(AppAttributes.CoutureLaneURL)/merchant/merchant-images/\(fileName)"),
                          indicator: true,
                          placeholder: nil)
        }
    }

}
