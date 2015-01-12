//
//  AppDelegate.swift
//  Photomania
//
//  Created by Afonso Graça on 09/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit
import CoreData


let FLICKR_FETCH = "Flickr Just Uploaded Fetch" // name of the Flickr fetching background download session
let FOREGROUND_FLICKR_FETCH_INTERVAL : Double = 20*60 // how often (in seconds) we fetch new photos if we are in the foreground
let BACKGROUND_FLICKR_FETCH_TIMEOUT : NSTimeInterval = 10 // how long we'll wait for a Flickr fetch to return when we're in the background
var FLICKR_DOWNLOAD_SESSION : NSURLSession? = nil

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NSURLSessionDownloadDelegate, UISplitViewControllerDelegate {

	// MARK: - Types
	var window: UIWindow?

	var flickrDownloadBackgroundURLSessionCompletionHandler : (() -> Void)?
	var flickrDownloadSession : NSURLSession? {
		get {
			if FLICKR_DOWNLOAD_SESSION == nil {
				var onceToken : dispatch_once_t = 0
				dispatch_once(&onceToken){
					// notice the configuration here is "backgroundSessionConfiguration:"
					// that means that we will (eventually) get the results even if we are not the foreground application
					// even if our application crashed, it would get relaunched (eventually) to handle this URL's results!
					let urlSessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(FLICKR_FETCH)
					FLICKR_DOWNLOAD_SESSION = NSURLSession(configuration: urlSessionConfig,
						delegate: self, // we MUST have a delegate for background configurations
						delegateQueue: nil) // nil means "a random, non-main-queue queue"
				}
			}
			return FLICKR_DOWNLOAD_SESSION
		}
	}
	var flickrForegroundFetchTimer : NSTimer?
	var photoDatabaseContext : NSManagedObjectContext? = nil {
		didSet {
			// we do some stuff when our Photo database's context becomes available
			// we kick off our foreground NSTimer so that we are fetching every once in a while in the foreground
			// we post a notification to let others know the context is available
			
			// every time the context changes, we'll restart our timer
			// so kill (invalidate) the current one
			self.flickrForegroundFetchTimer?.invalidate()
			self.flickrForegroundFetchTimer = nil
			
			var userInfo : [String : AnyObject]? = nil
			if let context = self.photoDatabaseContext {
				// this timer will fire only when we are in the foreground
				self.flickrForegroundFetchTimer = NSTimer.scheduledTimerWithTimeInterval(FOREGROUND_FLICKR_FETCH_INTERVAL, target: self, selector: "startFlickrFetch:", userInfo: nil, repeats: true)
				
				userInfo = [PhotoDatabaseAvailabilityContext : context]
			}
			
			// let everyone who might be interested know this context is available
			// this happens very early in the running of our application
			// it would make NO SENSE to listen to this radio station in a View Controller that was segued to, for example
			// (but that's okay because a segued-to View Controller would presumably be "prepared" by being given a context to work in)
			NSNotificationCenter.defaultCenter().postNotificationName(PhotoDatabaseAvailabilityNotification, object: self, userInfo: userInfo)
		}
	}
	
	// MARK: - UIApplicationDelegate
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// when we're in the background, fetch as often as possible (which won't be much)
		UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
		
		// we get our managed object context by creating it ourself in a category on PhotomaniaAppDelegate
		// but in your homework assignment, you must get your context from a UIManagedDocument
		// (i.e. you cannot use the method createMainQueueManagedObjectContext, or even use that approach)
		self.photoDatabaseContext = self.createMainQueueManagedObjectContext()
		
		// we fire off a Flickr fetch every time we launch (why not?)
		self.startFlickrFetch()
		
		//splitViewController visible
		if let splitViewController = self.window!.rootViewController as? UISplitViewController {
			splitViewController.delegate = self
			splitViewController.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
			splitViewController
		}
		// this return value has to do with handling URLs from other applications
		// don't worry about it for now, just return true
		return true
	}
	
	// this is called occasionally by the system WHEN WE ARE NOT THE FOREGROUND APPLICATION
	// in fact, it will LAUNCH US if necessary to call this method
	// the system has lots of smarts about when to do this, but it is entirely opaque to us
	func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		// so let's simply make a non-discretionary, non-background-session fetch here
		// we don't want it to take too long because the system will start to lose faith in us as a background fetcher and stop calling this as much
		// so we'll limit the fetch to BACKGROUND_FETCH_TIMEOUT seconds (also we won't use valuable cellular data)
		if let context = self.photoDatabaseContext {
			let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
			sessionConfig.allowsCellularAccess = false
			sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT // want to be a good background citizen!
			let session = NSURLSession(configuration: sessionConfig)
			let request = NSURLRequest(URL: FlickrFetcher.URLforRecentGeoreferencedPhotos())
			let task = session.downloadTaskWithRequest(request) {(localFile : NSURL!, response: NSURLResponse!, error : NSError!) -> Void in
				if let err = error {
					NSLog("Flickr background fetch failed: %@", err.localizedDescription)
					completionHandler(.NoData)
				}
				else {
					self.loadFlickrPhotosFromLocalURL(localFile, intoContext: self.photoDatabaseContext){
						completionHandler(.NewData)
					}
				}
			}
			task.resume()
		}
		else {
			completionHandler(.NoData) // no app-switcher update if no database!
		}
	}
	
	// this is called whenever a URL we have requested with a background session returns and we are in the background
	// it is essentially waking us up to handle it
	// if we were in the foreground iOS would just call our delegate method and not bother with this
	func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
		// this completionHandler, when called, will cause our UI to be re-cached in the app switcher
		// but we should not call this handler until we're done handling the URL whose results are now available
		// so we'll stash the completionHandler away in a property until we're ready to call it
		// (see flickrDownloadTasksMightBeComplete for when we actually call it)
		self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
	}
	
	// MARK: - SplitViewController Delegate
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
		return true;
	}
	
	// MARK: - Flickr Fetching
	// this will probably not work (task = nil) if we're in the background, but that's okay
	// (we do our background fetching in performFetchWithCompletionHandler:)
	// it will always work when we are the foreground (active) application
	
	func startFlickrFetch() {
		// getTasksWithCompletionHandler: is ASYNCHRONOUS
		// but that's okay because we're not expecting startFlickrFetch to do anything synchronously anyway
		self.flickrDownloadSession?.getTasksWithCompletionHandler({ (dataTasks : [AnyObject]!, uploadTasks : [AnyObject]!, downloadTasks : [AnyObject]!) -> Void in
			// let's see if we're already working on a fetch ...
			if downloadTasks.count == 0{
				// ... not working on a fetch, let's start one up
				let task = self.flickrDownloadSession?.downloadTaskWithURL(FlickrFetcher.URLforRecentGeoreferencedPhotos())
				task?.taskDescription = FLICKR_FETCH
				task?.resume()
			}
			else {
				// ... we are working on a fetch (let's make sure it (they) is (are) running while we're here)
				for task in downloadTasks {
					task.resume()
				}
			}
		})
	}
	
	func startFlickrFetch(timer: NSTimer) { // NSTimer target/action always takes an NSTimer as an argument
		self.startFlickrFetch()
	}
	
	// standard "get photo information from Flickr URL" code
	func flickrPhotosAtURL(url : NSURL) -> [AnyObject]? {
		if let flickrJSONData = NSData(contentsOfURL: url) {
			let flickrPropertyList : AnyObject? = NSJSONSerialization.JSONObjectWithData(flickrJSONData, options: nil, error: nil)
			return flickrPropertyList!.valueForKeyPath(FLICKR_RESULTS_PHOTOS) as? [AnyObject]
		}
		return nil
	}
	
	// gets the Flickr photo dictionaries out of the url and puts them into Core Data
	// this was moved here after lecture to give you an example of how to declare a method that takes a block as an argument
	// and because we now do this both as part of our background session delegate handler and when background fetch happens
	func loadFlickrPhotosFromLocalURL(localFile : NSURL, intoContext managedContext : NSManagedObjectContext?, whenDone : (()->())?) {
		if let context = managedContext {
			let photos = self.flickrPhotosAtURL(localFile)
			context.performBlock(){
				Photo.loadPhotosFromFlickr(photos as [[String : AnyObject]], context: context)
				context.save(nil)
				if let done = whenDone { done()}
			}
		}
		else {
			if let done = whenDone { done()}
		}
	}
	
	//MARK: - NSURLSessionDownloadDelegate
	
	// required by the protocol
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL localFile: NSURL) {
		// we shouldn't assume we're the only downloading going on ...
		if downloadTask.taskDescription == FLICKR_FETCH {
			// ... but if this is the Flickr fetching, then process the returned data
			self.loadFlickrPhotosFromLocalURL(localFile, intoContext: self.photoDatabaseContext){
				self.flickrDownloadTasksMightBeComplete()
			}
		}
	}
	
	
	// required by the protocol
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
		// we don't support resuming an interrupted download task
	}
	
	// required by the protocol
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		// we don't report the progress of a download in our UI, but this is a cool method to do that with
	}
	
	// not required by the protocol, but we should definitely catch errors here
	// so that we can avoid crashes
	// and also so that we can detect that download tasks are (might be) complete
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
		if error != nil && session == self.flickrDownloadSession! {
			NSLog("Flickr background download session failed: %@", error!.localizedDescription)
			self.flickrDownloadTasksMightBeComplete()
		}
	}
	
	// this is "might" in case some day we have multiple downloads going on at once
	func flickrDownloadTasksMightBeComplete() {
		if let completionHandler = self.flickrDownloadBackgroundURLSessionCompletionHandler {
			self.flickrDownloadSession?.getTasksWithCompletionHandler({ (dataTasks : [AnyObject]!, uploadTasks : [AnyObject]!, downloadTasks : [AnyObject]!) -> Void in
				// we're doing this check for other downloads just to be theoretically "correct"
				//  but we don't actually need it (since we only ever fire off one download task at a time)
				// in addition, note that getTasksWithCompletionHandler: is ASYNCHRONOUS
				//  so we must check again when the block executes if the handler is still not nil
				//  (another thread might have sent it already in a multiple-tasks-at-once implementation)
				if downloadTasks.count == 0 { // any more Flickr downloads left?
					// nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
					let handler = self.flickrDownloadBackgroundURLSessionCompletionHandler
					self.flickrDownloadBackgroundURLSessionCompletionHandler = nil
					if let download = handler {
						download()
					}
				}
				// else other downloads going, so let them call this method when they finish
			})
		}
	}
}

