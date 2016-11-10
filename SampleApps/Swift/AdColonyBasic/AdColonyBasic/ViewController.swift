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
        AdColony.configure(withAppID: Constants.adColonyAppID, zoneIDs: [Constants.adColonyZoneID], options: nil,
            completion:{(zones) in
                
                //AdColony has finished configuring, so let's request an interstitial ad
                self.requestInterstitial()
                
                //If the application has been inactive for a while, our ad might have expired so let's add a check for a nil ad object
                NotificationCenter.default.addObserver(self, selector:#selector(ViewController.onBecameActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
            }
        )
        
        //Show the user that we are currently loading videos
        self.setLoadingState()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.all
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    
    
    //=============================================
    // MARK:- AdColony
    //=============================================
    
    func requestInterstitial()
    {
        //Request an interstitial ad from AdColony
        AdColony.requestInterstitial(inZone: Constants.adColonyZoneID, options:nil,
                                     
            //Handler for successful ad requests
            success:{(newAd) in
                
                //Once the ad has finished, set the loading state and request a new interstitial
                newAd.setClose({
                    self.ad = nil
                    
                    self.setLoadingState()
                    self.requestInterstitial()
                })
                
                //Interstitials can expire, so we need to handle that event also
                newAd.setExpire({
                    self.ad = nil
                    
                    self.setLoadingState()
                    self.requestInterstitial()
                })
                
                //Store a reference to the returned interstitial object
                self.ad = newAd
                
                //Show the user we are ready to play a video
                self.setReadyState()
            },
            
            //Handler for failed ad requests
            failure:{(error) in
                NSLog("SAMPLE_APP: Request failed with error: " + error.localizedDescription + " and suggestion: " + error.localizedRecoverySuggestion!)
            }
        )
    }
    
    @IBAction func launchInterstitial(_ sender: AnyObject)
    {
        //Display our ad to the user
        if let ad = self.ad {
            if (!ad.expired) {
                ad.show(withPresenting: self)
            }
        }
    }
    
    
    //=============================================
    // MARK:- UI
    //=============================================

    func setLoadingState()
    {
        self.launchButton.isHidden = true
        self.launchButton.alpha = 0.0
        self.loadingLabel.isHidden = false
        self.spinner.startAnimating()
    }
    
    func setReadyState()
    {
        self.loadingLabel.isHidden = true
        self.launchButton.isHidden = false
        self.spinner.stopAnimating()
        
        UIView.animate(withDuration: 1.0) {
            self.launchButton.alpha = 1.0
        }
    }
    
    
    //=============================================
    // MARK:- Event Handlers
    //=============================================

    func onBecameActive()
    {
        //If our ad has expired, request a new interstitial
        if (self.ad == nil) {
            self.requestInterstitial()
        }
    }
}
