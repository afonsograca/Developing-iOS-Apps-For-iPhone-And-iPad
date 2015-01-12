//
//  AddPhotoViewController.swift
//  Photomania Map
//
//  Created by Afonso Graça on 01/12/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit
import MapKit
import MobileCoreServices

let UNWIND_SEGUE_IDENTIFIER = "Do Add Photo"
class AddPhotoViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var subtitleTextField: UITextField!
	@IBOutlet weak var imageView: UIImageView!
	var image : UIImage? {
		get { return self.imageView.image }
		set{
			self.imageView.image = newValue
			
			if let imgURL = self.imageURL {
				NSFileManager.defaultManager().removeItemAtURL(imgURL, error: nil)
				self.imageURL = nil
			}
			if let thumbURL = self.thumbnailURL {
				NSFileManager.defaultManager().removeItemAtURL(thumbURL, error: nil)
				self.thumbnailURL = nil
			}
			if newValue != nil {
				if let url = self.uniqueDocumentURL() {
					if UIImageJPEGRepresentation(newValue!, 1.0).writeToURL(url, atomically: true) {
						self.imageURL = url
						
						let thumbnail = url.URLByAppendingPathExtension("thumbnail")
						
						if self.thumbnailURL != thumbnail {
							
							let thumbImage = newValue!.imageByScalingToSize(CGSizeMake(75, 75))
							if UIImageJPEGRepresentation(thumbImage, 0.5).writeToURL(thumbnail, atomically: true) {
								self.thumbnailURL = thumbnail
							}
						}
					}
				}
			}
		}
	}
	
	var photographerTakingPhoto : Photographer?
	private(set) var addedPhoto : Photo?
	
	var locationManager : CLLocationManager!
	var location : CLLocation?
	var locationErrorCode: Int = 0
	
	var imageURL : NSURL?
	var thumbnailURL : NSURL?
	
	@IBAction func takePhoto() {
		let uiipc = UIImagePickerController()
		uiipc.delegate = self
		
		uiipc.mediaTypes = [kUTTypeImage]
		uiipc.sourceType = .Camera
		uiipc.editing = true
		
		self.presentViewController(uiipc, animated: true, completion: nil)
	}
	
	@IBAction func cancel() {
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK: - Localized Strings
	
	let ALERT_NO_PHOTO_TAKEN = NSLocalizedString("ALERT_NO_PHOTO_TAKEN", tableName: "AddPhotoViewController", comment: "User tried to dismiss modal controller to add a photo, but had not taken a photo at that point.")
	let ALERT_CANT_ADD_PHOTO = NSLocalizedString("ALERT_CANT_ADD_PHOTO", tableName: "AddPhotoViewController", comment: "Alert message delivered when there is something that prevents the user from adding a new photo to the database that the user can do nothing about.")
	let ALERT_TITLE_REQUIRED = NSLocalizedString("ALERT_TITLE_REQUIRED", tableName: "AddPhotoViewController", comment: "User tried to dismiss modal controller to add a photo, but had not specified a title for the photo, which is required.")
	let ALERT_LOCATION_UNKNOWN_YET = NSLocalizedString("ALERT_LOCATION_UNKNOWN_YET", tableName: "AddPhotoViewController", comment: "User tried to dismiss modal controller to add a photo, but the controller had not (yet) found the location the photo was taken.")
	let ALERT_LOCATION_SERVICES_DISABLED = NSLocalizedString("ALERT_LOCATION_SERVICES_DISABLED", tableName: "AddPhotoViewController", comment: "User tried to dismiss modal controller to add a photo, but the location the photo was taken could not be found because the user needs to enable location services in the Settings application.")
	let ALERT_LOCATION_NETWORK_DISABLED = NSLocalizedString("ALERT_LOCATION_NETWORK_DISABLED", tableName: "AddPhotoViewController", comment: "User tried to dismiss modal controller to add a photo, but the location the photo was taken could not be found maybe because the user has no network connection active.")
	let ALERT_LOCATION_UNKNOWN = NSLocalizedString("ALERT_LOCATION_UNKNOWN", tableName: "AddPhotoViewController", comment: "User tried to dismiss modal controller to add a photo, but the controller cannot figure out the location the photo was taken.")
	let ALERT_TITLE_ADD_PHOTO = NSLocalizedString("ALERT_TITLE_ADD_PHOTO", tableName: "AddPhotoViewController", comment: "Title of an alert that appears when there is a problem adding a photo to the database.")
	let ALERT_DISMISS_BUTTON = NSLocalizedString("ALERT_DISMISS_BUTTON", tableName: "AddPhotoViewController", comment: "Text on button which dismisses an alert which explained a problem adding a photo to the database.")
	
	// MARK: - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == UNWIND_SEGUE_IDENTIFIER {
			if let context = self.photographerTakingPhoto?.managedObjectContext {
				let photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as Photo
				photo.title = self.titleTextField.text
				photo.subtitle = self.subtitleTextField.text
				photo.whoTook = self.photographerTakingPhoto!
				photo.latitude = self.location!.coordinate.latitude
				photo.longitude = self.location!.coordinate.longitude
				photo.imageURL = self.imageURL!.absoluteString!
				photo.thumbnailURL = self.thumbnailURL!.absoluteString!
				
				self.addedPhoto = photo
				
				self.imageURL = nil
				self.thumbnailURL = nil
			}
		}
	}
	
	override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
		if identifier == UNWIND_SEGUE_IDENTIFIER {
			if self.image == nil {
				self.alert(ALERT_NO_PHOTO_TAKEN) //"No photo taken!"
				return false
			}
			else if self.titleTextField.text.isEmpty {
				self.alert(ALERT_TITLE_REQUIRED) //"Title required!"
				return false
			}
			else if self.location == nil {
				switch self.locationErrorCode {
				case CLError.LocationUnknown.rawValue:
					self.alert(ALERT_LOCATION_UNKNOWN_YET) //"Couldn't figure out where this photo was taken (yet)."
				case CLError.Denied.rawValue:
					self.alert(ALERT_LOCATION_SERVICES_DISABLED) //"Location Services disabled under Privacy in Settings application."
				case CLError.Network.rawValue:
					self.alert(ALERT_LOCATION_NETWORK_DISABLED) //"Can't figure out where this photo is being taken.  Verify your connection to the network."
				default:
					self.alert(ALERT_LOCATION_UNKNOWN) //"Can't figure out where this photo is being taken, sorry."
				}
				return false
			}
			else {
				return true
			}
		}
		else {
			return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
		}
	}
	
	// MARK: - Alerts
	
	func alert(msg : String) {
		UIAlertView(title: ALERT_TITLE_ADD_PHOTO, message: msg, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: ALERT_DISMISS_BUTTON).show() //"Add Photo"
	}
	
	func fatalAlert(msg : String) {
		UIAlertView(title: ALERT_TITLE_ADD_PHOTO, message: msg, delegate: self, cancelButtonTitle: nil, otherButtonTitles: ALERT_DISMISS_BUTTON).show() //"Add Photo"
	}
	
	// MARK: - UITextField Delegate Methods
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	// MARK: - UIAlertView Delegate Methods
	
	func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
		self.cancel()
	}
	
	// MARK: - CLLocationManager Delegate Methods
	
	func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
		self.location = locations.last as? CLLocation
	}
	
	func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
		self.locationErrorCode = error.code
	}
	
	// MARK: - UIImagePickerController Delegate Methods
	
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
		var image = info[UIImagePickerControllerEditedImage] as? UIImage
		if image == nil {
			image = info[UIImagePickerControllerOriginalImage] as? UIImage
		}
		
		self.image = image
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK: - Camera Availability
	
	func canAddPhoto() -> Bool {
		
		if UIImagePickerController.isSourceTypeAvailable(.Camera) {
			if let availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera){
				if let camera = find(availableMediaTypes as [String], kUTTypeImage as String) {
					if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Restricted {
						return true
					}
				}
			}
		}
		return false
	}
	
	// MARK: - Image Properties
	
	func uniqueDocumentURL() -> NSURL? {
		let documentDirectories = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
		let unique = "\(floor(NSDate.timeIntervalSinceReferenceDate()))"
		return documentDirectories.first?.URLByAppendingPathComponent(unique)
	}
	
	// MARK: - Initialisation
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if !self.canAddPhoto() {
			self.fatalAlert(ALERT_CANT_ADD_PHOTO) //"Sorry, your device cannot add a photo."
		}
		else {
			self.locationManager.startUpdatingLocation()
		}
	}
	
	// MARK: - De-Initialisation
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		self.locationManager.stopUpdatingLocation()
	}
}
