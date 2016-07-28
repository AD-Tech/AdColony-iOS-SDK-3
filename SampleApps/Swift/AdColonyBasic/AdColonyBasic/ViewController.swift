//
//  ViewController.swift
//  AdColonyBasic
//
//  Copyright (c) 2016 AdColony. All rights reserved.
//

import UIKit
import Foundation

struct Constants
{
    static let adColonyAppID = "appbdee68ae27024084bb334a"
    static let adColonyZoneID = "vzf8fb4670a60e4a139d01b5"
}


class ViewController: UIViewController
{
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var ad: AdColonyInterstitial?
    
    
    //=============================================
    // MARK:- UIViewController Overrides
    //=============================================
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Configure AdColony once
        AdColony.configureWithAppID(Constants.adColonyAppID, zoneIDs: [Constants.adColonyZoneID], options: nil,
            completion:
            { (zones) in
                self.requestInterstitial()
            
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector:#selector(ViewController.onBecameActive),
                    name: UIApplicationDidBecomeActiveNotification,
                    object: nil)
            }
        )
        
        //Show the user that we are currently loading videos
        self.setLoadingState()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.All
    }
    
    override func shouldAutorotate() -> Bool
    {
        return true
    }
    
    //=============================================
    // MARK:- AdColony
    //=============================================
    
    func requestInterstitial()
    {
        //Request an interstitial ad from AdColony
        AdColony.requestInterstitialInZone(Constants.adColonyZoneID, options:nil,
            success:
            { (newAd) in
                //Once the ad has finished, set the loading state and request a new interstitial
                newAd.setClose(
                    {
                        self.setLoadingState()
                        self.requestInterstitial()
                    }
                )
                
                newAd.setExpire(
                    {
                        self.ad = nil
                    }
                )
                
                self.ad = newAd
                
                self.setReadyState()
            },
            failure:
            { (error) in
                NSLog("SAMPLE_APP: Request failed with error: " + error.localizedDescription + " and suggestion: " + error.localizedRecoverySuggestion!)
            }
        )
    }
    
    @IBAction func launchInterstitial(sender: AnyObject)
    {
        if let ad = self.ad
        {
            if (!ad.expired)
            {
                ad.showWithPresentingViewController(self)
            }
        }
    }
    
    
    //=============================================
    // MARK:- UI
    //=============================================

    func setLoadingState()
    {
        self.launchButton.hidden = true
        self.launchButton.alpha = 0.0
        self.loadingLabel.hidden = false
        self.spinner.startAnimating()
    }
    
    func setReadyState()
    {
        self.loadingLabel.hidden = true
        self.launchButton.hidden = false
        self.spinner.stopAnimating()
        UIView.animateWithDuration(1.0)
        {
            self.launchButton.alpha = 1.0
        }
    }
    
    
    //=============================================
    // MARK:- Event Handlers
    //=============================================

    func onBecameActive()
    {
        if (self.ad == nil)
        {
            self.requestInterstitial()
        }
    }
}
