//
//  ViewController.swift
//  AdColonyInstantFeed
//
//  Copyright (c) 2016 AdColony. All rights reserved.
//

import UIKit

struct Constants
{
    static let ad = "ad"
    static let post = "post"
    static let adView = "adView"
    static let adZone = "zone"
    static let cellType = "cellType"
    static let postImage = "postImage"
    static let postImageAR = "aspectRatio"
    
    static let feedCellImage = "FeedCellImage"
    static let feedCellAd = "FeedCellAd"
    
    static let adColonyAppID = "app2086517932ad4b608a"
    static let adColonyZoneID = "vz7c0765ee52af4d67b9"
    
    static let adViewCellIndex = 4
    static let adQueueLimit = 2
    
    static let adViewWidth:CGFloat = 300.0
    static let adViewHeight:CGFloat = 169.0
    static let adViewCellHeight:CGFloat = 277.0
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var posts = [[String : Any?]]()
    var ads = [AdColonyNativeAdView]()
    
    var active: Bool = false
    
    
    //===================================================
    // MARK:- UIViewController Overrides
    //===================================================
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Configure AdColony once
        AdColony.configure(withAppID: Constants.adColonyAppID, zoneIDs: [Constants.adColonyZoneID], options: nil, completion: { (zones) in self.requestAd() })
        
        //Hardcoded data source for our feed
        posts = [[Constants.cellType : Constants.post, Constants.postImage : "Taco-Bell", Constants.postImageAR : 3.2 as CGFloat],
                 [Constants.cellType : Constants.post, Constants.postImage : "Pacific",   Constants.postImageAR : 1.78 as CGFloat],
                 [Constants.cellType : Constants.post, Constants.postImage : "MLB",       Constants.postImageAR : 1.45 as CGFloat],
                 [Constants.cellType : Constants.post, Constants.postImage : "MTV",       Constants.postImageAR : 1.68 as CGFloat],
                 [Constants.cellType : Constants.post, Constants.postImage : "Fallon",    Constants.postImageAR : 1.33 as CGFloat],
                 [Constants.cellType : Constants.post, Constants.postImage : "Jobs",      Constants.postImageAR : 1.7 as CGFloat],
                 [Constants.cellType : Constants.post, Constants.postImage : "Pugs",      Constants.postImageAR : 1.41 as CGFloat],
                 [Constants.cellType : Constants.post, Constants.postImage : "Cashmore",  Constants.postImageAR : 1.68 as CGFloat]]
        
        //Register our nibs
        tableView.register(UINib(nibName: Constants.feedCellImage, bundle: nil), forCellReuseIdentifier: Constants.feedCellImage)
        tableView.register(UINib(nibName: Constants.feedCellAd, bundle: nil), forCellReuseIdentifier: Constants.feedCellAd)
        
        //Hide the table view until we have at least one ready ad
        tableView.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            return UIInterfaceOrientationMask.all
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    
    
    //===================================================
    // MARK:- Requesting Ads
    //===================================================
    
    func requestAd()
    {
        AdColony.requestNativeAdView(inZone: Constants.adColonyZoneID, size: CGSize(width: 300, height: 170), options: nil, viewController: self,
            success:{ (adView) in
                NSLog("AdColony returned a valid native ad view for zone: " + adView.zoneID)
                
                //Native video start handler
                adView.setStart({ _ in
                    NSLog("AdColonyNativeAdView video started")
                })
                
                //Native video finish handler
                adView.setFinish({ _ in
                    NSLog("AdColonyNativeAdView video finished")
                        
                    //If the native ad has been expanded to fullscreen, use the close handler instead
                    guard !adView.opened else { return }
                    
                    self.onAdComplete(adView)
                })
                
                //Native video open handler
                adView.setOpen({ _ in
                    NSLog("AdColonyNativeAdView opened")
                })
                
                //Native ad close handler
                adView.setClose({ _ in
                    NSLog("AdColonyNativeAdView closed")
                    self.onAdComplete(adView)
                })
                
                //Try to insert the new ad view into our feed
                //If it is already full, queue the new ad for later use
                if !self.updateFeedWithAdView(adView)
                {
                    NSLog("Feed is full of ads right now. Queuing ad for later use");
                    self.ads.append(adView)
                }
                
                //Unhide the table view if this handler indicates at least one ad is ready
                if !self.active {
                    self.spinner.stopAnimating()
                    self.loadingLabel.isHidden = true
                    self.tableView.isHidden = false
                    self.active = true
                }
                
                //Try to get a new ad
                if self.ads.count <= Constants.adQueueLimit {
                    self.requestAd()
                }
            },
            failure:{ (error) in
                NSLog("AdColony returned an error: " + error.localizedDescription + " with suggestion: " + error.localizedRecoverySuggestion!)
                self.requestAd();
            }
        )
    }
    
    func onAdComplete(_ ad: AdColonyNativeAdView)
    {
        //If we have no more ads ready, just leave the finished one in the feed
        guard self.ads.count != 0 else { return }
        
        //Try to get an ad that's ready to be viewed and then try to insert it into our feed
        //*** NOTE: Replacing finished ads with new ones will increase publisher revenue
        guard let newAd = self.ads.first else { return }
        
        //Try to insert the next ad into our feed
        if self.updateFeedWithAdView(newAd) {
            //Update the queue of waiting ads
            self.ads.remove(at: 0)
            
            //Destroy the current ad to free up resources
            ad.removeFromSuperview()
            ad.destroy()
        }
    }
    
    //===================================================
    // MARK:- UITableViewDataSource
    //===================================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellConfig = posts[(indexPath as NSIndexPath).row]
        let cellType = cellConfig[Constants.cellType] as! String
        
        //There are only two cases to consider here:
        // 1. The cell cannot be an ad
        // 2. The cell is an ad and we have an AdColonyNativeAdView
        if cellType == Constants.post {
            return self.createStandardCell(indexPath)
        } else {
            let adView = cellConfig[Constants.adView] as! AdColonyNativeAdView
            return self.createCellWithAdView(adView, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let cellConfig = posts[(indexPath as NSIndexPath).row]
        let cellType = cellConfig[Constants.cellType] as! String
        
        //There are only two cases to consider here:
        // 1. The cell cannot be an ad
        // 2. The cell is an ad and we have an AdColonyNativeAdView
        if cellType == Constants.post {
            return self.getStandardCellHeight(cellConfig)
        } else {
            return Constants.adViewCellHeight
        }
    }
    
    
    //===================================================
    // MARK:- Feed Cell Creation
    //===================================================
    
    func createCellWithAdView(_ adView: AdColonyNativeAdView, indexPath: IndexPath) -> FeedCellAd
    {
        let adCell = tableView.dequeueReusableCell(withIdentifier: Constants.feedCellAd, for: indexPath) as! FeedCellAd
        
        //Configure the cell's view elements using the properties of the AdColonyNativeAdView
        adCell.advertiserLabel.text = adView.advertiserName
        adCell.iconView.image  = adView.advertiserIcon
        adCell.titleLabel.text = adView.adTitle

        //Size the native ad view appropriately
        adView.frame = CGRect(x: 0, y: 0, width: Constants.adViewWidth, height: Constants.adViewHeight)
        
        //Configure the native ad's engagement button
        adView.engagementButton?.backgroundColor = UIColor.black
        
        //Add the video view to the cell
        adCell.adView = adView
        
        return adCell
    }
    
    func createStandardCell(_ indexPath: IndexPath) -> FeedCellImage
    {
        //Create a standard cell with an image
        let cellConfig = posts[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.feedCellImage, for: indexPath) as! FeedCellImage
        if let image = UIImage(named: cellConfig[Constants.postImage] as! String) {
            cell.background.image = image
        }
        
        return cell
    }
    
    func getStandardCellHeight(_ cellConfig: Dictionary<String, Any?>) -> CGFloat
    {
        let aspectRatio = cellConfig[Constants.postImageAR] as! CGFloat
        let tableWidth  = tableView.frame.size.width
        return tableWidth / aspectRatio
    }
    
    
    //===================================================
    // MARK:- Updating Feed and Data Source
    //===================================================
    
    func updateFeedWithAdView(_ adView: AdColonyNativeAdView) -> Bool
    {
        let cellConfig = posts[Constants.adViewCellIndex]
        let cellType = cellConfig[Constants.cellType] as! String
        
        //We want to insert an ad view in the 5th position of the feed if possible
        //If the cell at that position is currently an image, insert an ad view at that index
        if cellType != Constants.ad {
            self.updateDataSourceWithAdView(adView, index: Constants.adViewCellIndex)
            return true
        }
        
        //If the current ad view is finished, replace it with the new one
        //*** NOTE: Replacing finished ads with new ones will increase publisher revenue
        if let oldAdView = cellConfig[Constants.adView] as? AdColonyNativeAdView {
            if oldAdView.finished {
                posts.remove(at: Constants.adViewCellIndex)
                self.updateDataSourceWithAdView(adView, index: Constants.adViewCellIndex)
                return true
            }
        }
        
        return false
    }
    
    func updateDataSourceWithAdView(_ adView: AdColonyNativeAdView, index: Int)
    {
        //Update our data source with the new ad view and reload the table view
        posts.insert([Constants.cellType : Constants.ad, Constants.adView : adView], at: index)
        tableView.reloadData()
    }
    
    func removeCurrentAdViewFromDataSource()
    {
        //Remove the old ad view from our data source
        let cellConfig = posts[Constants.adViewCellIndex]
        if let _ = cellConfig[Constants.adView] {
            posts.remove(at: Constants.adViewCellIndex)
        }
    }
    
    
    //===================================================
    // MARK:- UITableViewDelegate
    //===================================================
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        guard let adCell = cell as? FeedCellAd else { return }
        
        //Resume the ad if our table view is going to display it
        adCell.adView?.resume()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        guard let adCell = cell as? FeedCellAd else { return }
        
        //Pause the ad if our table view is going to display it
        adCell.adView?.pause()
    }
}
