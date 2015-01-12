//
//  ImageViewController.swift
//  Imaginarium
//
//  Created by Afonso Graça on 28/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

	// MARK: - Properties
	var imageURL : NSURL? {
		didSet {
			self.startDownloadingImage()
			//self.image = UIImage(data: NSData(contentsOfURL: self.imageURL!)!)!
		}
	}
	var imageView = UIImageView()
	var image : UIImage? {
		get {return self.imageView.image }
		set {
			self.imageView.image  = newValue
			if let img = newValue {
				self.imageView.frame = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
			}
			if let scroll = self.scrollview {
				scroll.zoomScale = 1.0
				scroll.contentSize = self.image != nil ? self.image!.size : CGSizeZero
			}
			if let spinner = self.spinner {
				spinner.stopAnimating()
			}
		}
	}
	@IBOutlet weak var scrollview: UIScrollView! {
		didSet {
			self.scrollview.minimumZoomScale = 0.2
			self.scrollview.maximumZoomScale = 2.0
			self.scrollview.delegate = self
			self.scrollview.contentSize = self.image != nil ? self.image!.size : CGSizeZero

		}
	}
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	 
	// MARK: - Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		self.scrollview.addSubview(self.imageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	// MARK: - UIScrollViewDelegate method implementations
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return self.imageView
	}
	
	// MARK: - Content Retrieve (Threaded)
	func startDownloadingImage() {
		self.image = nil
		if let spinner = self.spinner {
			spinner.startAnimating()
		}
		if let url = self.imageURL {
			let request = NSURLRequest(URL: url)
			let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
			let session = NSURLSession(configuration: configuration)
			let task = session.downloadTaskWithRequest(request) { (localFile  : NSURL!, response : NSURLResponse!, error: NSError!) -> Void in
				if error == nil {
					if request.URL.isEqual(self.imageURL!) {
						let image = UIImage(data: NSData(contentsOfURL: localFile)!)
						dispatch_async(dispatch_get_main_queue()){
							self.image = image
						}
					}
				}
			}
			task.resume()
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
