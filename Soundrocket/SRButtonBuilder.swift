//
//  SRButtonBuilder.swift
//  Soundrocket
//
//  Created by Sebastian Boldt on 14.02.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

import UIKit

class SRButtonBuilder: NSObject {
    @objc
    class func buttonForFAKIcon (_ icon: FAKIcon,size:CGFloat,selector: Selector,target: AnyObject) -> UIBarButtonItem {
        
        icon.addAttribute(NSAttributedString.Key.foregroundColor.rawValue, value: UIColor.white)
        let image = icon.image(with: CGSize(width: size, height: size))
        
        icon.iconFontSize = size;
        let leftImage = icon.image(with: CGSize(width: size, height: size))
        
        return UIBarButtonItem(image: image, landscapeImagePhone: leftImage, style: .plain, target: target, action:selector)
    }
}


