//
//  JustPostedFlickrPhotosTVC.swift
//  Shutterbug
//
//  Created by Afonso Graça on 29/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class JustPostedFlickrPhotosTVC: FlickrPhotosTVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.fetchPhotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func fetchPhotos() {
		self.refreshControl?.beginRefreshing()
		let url = FlickrFetcher.URLforRecentGeoreferencedPhotos()
		// WARNING:  Blocking Main thread
		let  fetchQ = dispatch_queue_create("flickr fetcher", nil)
		dispatch_async(fetchQ){
			let jsonResults = NSData(contentsOfURL: url)
			let propertyListResults = NSJSONSerialization.JSONObjectWithData(jsonResults!, options: NSJSONReadingOptions.MutableContainers, error: nil) as [ String : AnyObject]
			
			//NSLog("Flickr results: \(propertyListResults)")
			var photos = (propertyListResults as AnyObject).valueForKeyPath(FLICKR_RESULTS_PHOTOS) as [[String : AnyObject]]
			
			dispatch_async(dispatch_get_main_queue()){
				self.refreshControl?.endRefreshing()
				self.photos = photos
			}
		}
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
