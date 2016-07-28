//
//  ViewController.swift
//  AdColonyV4VC
//
//  Copyright (c) 2016 AdColony. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var background:    UIImageView!
    @IBOutlet weak var button:        UIButton!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var statusLabel:   UILabel!
    @IBOutlet weak var spinner:       UIActivityIndicatorView!
    
    var ad: AdColonyInterstitial?

    
    //=============================================
    // MARK:- UIViewController Overrides
    //=============================================
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Initialize AdColony on initial launch
        AdColony.configureWithAppID(Constants.adColonyAppID, zoneIDs: [Constants.adColonyZoneID], options: nil,
            completion:
            { (zones) in
                //Set the zone's reward handler
                //This implementation is designed for client-side virtual currency without a server
                //It uses NSUserDefaults for persistent client-side storage of the currency balance
                //For applications with a server, contact the server to retrieve an updated currency balance
                let zone = zones.first
                zone?.setReward(
                    { (success, name, amount) in
                        if (success)
                        {   //Get currency balance from persistent storage and update it
                            let storage = NSUserDefaults.standardUserDefaults()
                            let wrappedBalance = storage.objectForKey(Constants.currencyBalance)
                            var balance: Int = 0
                            if let nonNilNumWrappedBalance = wrappedBalance as? NSNumber
                            {
                                balance = Int(nonNilNumWrappedBalance.unsignedIntegerValue)
                            }
                            balance += Int(amount)
                            
                            //Persist the currency balance
                            let newBalance: NSNumber = balance
                            storage.setObject(newBalance, forKey: Constants.currencyBalance)
                            storage.synchronize()
                            
                            //Update the UI with the new balance
                            self.updateCurrencyBalance()
                        }
                    }
                )
                
                //If the application has been inactive for a while, our ad might have expired so let's add a check for a nil ad object
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector: #selector(ViewController.onBecameActive),
                    name: UIApplicationDidBecomeActiveNotification,
                    object: nil)
                
                //AdColony has finished configuring, so let's request an interstitial ad
                self.requestInterstitial()
            }
        )
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad
        {
            self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        }
        else
        {
            self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        }
        
        self.updateCurrencyBalance()
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
                //Handler for successful ad requests
            
                //Once the ad has finished, set the loading state and request a new interstitial
                newAd.setClose(
                    {
                        self.setLoadingState()
                        self.requestInterstitial()
                    }
                )

                //Interstitials can expire, so we need to handle that event also
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
                //Handler for failed ad requests
                NSLog("SAMPLE_APP: Request failed with error: " + error.localizedDescription + " and suggestion: " + error.localizedRecoverySuggestion!)
            }
        )
    }
    
    @IBAction func triggerVideo(sender: AnyObject)
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
        self.spinner.hidden = false
        self.spinner.startAnimating()
        self.button.alpha = 0.0
        UIView.animateWithDuration(1.0)
        {
            self.statusLabel.alpha = 1.0
        }
    }
    
    func setReadyState()
    {
        self.spinner.stopAnimating()
        self.spinner.hidden = true
        self.statusLabel.alpha = 0.0
        UIView.animateWithDuration(1.0)
        {
            self.button.alpha = 1.0
        }
    }
    
    func updateCurrencyBalance()
    {
        //Get currency balance from persistent storage and display it
        let storage = NSUserDefaults.standardUserDefaults()
        let wrappedBalance = storage.objectForKey(Constants.currencyBalance)
        var balance: Int = 0
        if let nonNilNumWrappedBalance = wrappedBalance as? NSNumber
        {
            balance = Int(nonNilNumWrappedBalance.unsignedIntegerValue)
        }
        
        self.currencyLabel.text = String(format: "%d", balance)
    }
    
    
    //=============================================
    // MARK:- Event Handlers
    //=============================================

    func onBecameActive()
    {
        //If our ad has expired, request a new interstitial
        if (self.ad == nil)
        {
            self.requestInterstitial()
        }
    }
}
