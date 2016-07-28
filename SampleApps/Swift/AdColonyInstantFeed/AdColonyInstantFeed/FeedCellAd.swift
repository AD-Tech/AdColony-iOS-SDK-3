//
//  FeedCellAd.swift
//  AdColonyInstantFeed
//
//  Created by Owain Moss on 2/11/15.
//  Copyright (c) 2015 AdColony. All rights reserved.
//

import Foundation
import UIKit

class FeedCellAd: UITableViewCell
{
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var advertiserLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var adContainer: UIView!
    
    var adView: AdColonyNativeAdView? {
        willSet(newAdView) {
            if let view = newAdView as AdColonyNativeAdView? {
               adContainer.addSubview(view)
            }
        }
    }
    
    //===================================================
    // MARK:- Pause/Resume
    //===================================================
    
    func pause() -> Void
    {
        adView?.pause()
    }
    
    func resume() -> Void
    {
        adView?.resume()
    }
}
