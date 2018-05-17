//
//  AppAttributes.swift
//  CoutureLane
//
//  Created by Greg Anderson on 3/26/18.
//  Copyright © 2018 Couture Lane. All rights reserved.
//

// This class wraps and centralizes a set of system-wide defines

import UIKit

@objc
class AppAttributes: NSObject {
    
    @objc public static let CoutureLaneURL = "https://login.couturelane.com"
    @objc public static let ImagesURL = "http://d3nzx68b1h1rsc.cloudfront.net"
    
    // MARK: Fonts
    @objc public static let defaultFontName = "Geomanist-Regular"
    
    // MARK: Colors
    @objc public static let greyishColor =
        UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
    @objc public static let greyishBrownColor =
        UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
    @objc public static let warmGrayColor =
        UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1.0)
    @objc public static let duskBlueColor =
        UIColor(red: 48/255, green: 92/255, blue: 164/255, alpha: 1.0)
    @objc public static let mediumGrayColor =
        UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1.0)
    @objc public static let veryLightGrayColor =
        UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1.0)
    @objc public static let reddishBorderColor =
        UIColor(red: 255/255, green: 104/255, blue: 88/255, alpha: 1.0)

    // MARK: UI styles
    // Font and color of UINavigationController Bar Items
    @objc public static let navigationBarItemAttributes =
        [NSAttributedStringKey.font: UIFont(name: defaultFontName, size: 18)!,
         NSAttributedStringKey.foregroundColor: greyishBrownColor]
    
    // MARK: Other definitions
    @objc public static let onboardingStoryboardName = "Onboarding"
    // Names and StoryboardIDs of the VCs in the Sign Up process.  The screens will appear onscreen
    // in the order in which they appear in the array.  (Yes! You can shuffle them around here.)
    @objc public static let signUpScreenStoryboardIDs = [
        "SignUp_EmailVC",
        "SignUp_PasswordVC",
        "SignUp_MobileNumberVC",
        "SignUp_VerificationCodeVC",
        "SignUp_NameVC",
        "SignUp_ScreenNameVC",
        "SignUp_AgeVC",
        "SignUp_ProfilePictureVC",
        ]
    
    // The indices of the various tab functions on the Main Tab Bar:
    
    @objc public static let styleFeedFunctionTabIndex = 0
    @objc public static let discoveryFunctionTabIndex = 1
    @objc public static let postFunctionTabIndex = 2
    @objc public static let wishlistFunctionTabIndex = 3
    @objc public static let userProfileFunctionTabIndex = 4
    
}
