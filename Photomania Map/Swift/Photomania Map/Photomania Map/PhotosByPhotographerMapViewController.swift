//
//  PhotosByPhotographerMapViewController.swift
//  Photomania Map
//
//  Created by Afonso Graça on 25/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit
import MapKit

class PhotosByPhotographerMapViewController: UIViewController, MKMapViewDelegate {

	// MARK: - Types
	
	var photographer : Photographer?{
		didSet{
			self.title = self.photographer?.name
			
			let request = NSFetchRequest(entityName: "Photo")
			request.predicate = NSPredicate(format: "whoTook = %@", self.photographer!)
			self.photosByPhotographer = self.photographer?.managedObjectContext?.executeFetchRequest(request, error: nil) as? [Photo]
			
			if self.mapView != nil {
				self.updateMapViewAnnotations()
			}
			
			if self.addPhotoBarButtonItem != nil {
				self.updateAddPhotoBarButtonItem()
			}
		}
	}
	
	@IBOutlet weak var mapView: MKMapView!{
		didSet {
			self.mapView.delegate = self
			self.updateMapViewAnnotations()
		}
	}
	
	@IBOutlet weak var addPhotoBarButtonItem: UIBarButtonItem!
	
	var photosByPhotographer : [Photo]?
	
	// MARK: - Annotations
	
	func updateMapViewAnnotations() {
		self.mapView.removeAnnotations(self.mapView.annotations)
		self.mapView.addAnnotations(self.photosByPhotographer)
		self.mapView.showAnnotations(self.photosByPhotographer, animated: true)
	}
	
	func updateLeftCalloutAccessoryViewInAnnotationView( annotationView : MKAnnotationView) {
		if let leftCalloutAccessoryView = annotationView.leftCalloutAccessoryView as? UIImageView	{
			if let photo = annotationView.annotation as? Photo {
				leftCalloutAccessoryView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: photo.imageURL)!)!)
			}
		}
	}
	
	// MARK: - MKMapView Delegate Methods
	
	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		let reuseId = "PhotosByPhotographerMapViewController"
		if let view = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) {
			view.annotation = annotation
			
			return view
		}
		else {
			let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			
			view.canShowCallout = true
			
			view.leftCalloutAccessoryView = UIImageView(frame: CGRect(x: 0, y: 0, width: 46, height: 46))
			
			let disclosureButton = UIButton()
			let disclosure = UITableViewCell()
			disclosureButton.addSubview(disclosure)
			disclosureButton.sizeToFit()
			disclosure.frame = disclosureButton.bounds
			disclosure.accessoryType = .DisclosureIndicator
			disclosure.userInteractionEnabled = false
			
			
			view.rightCalloutAccessoryView = disclosureButton
			return view
		}
	}
	
	func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
		self.updateLeftCalloutAccessoryViewInAnnotationView(view)
	}
	
	func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
		self.performSegueWithIdentifier("Show Photo", sender: view)
	}
	
	// MARK: - Navigation
	
	func updateAddPhotoBarButtonItem() {
		if let canAddPhoto = self.photographer?.isUser() {
			if !canAddPhoto {
				self.navigationItem.rightBarButtonItems?.removeAll(keepCapacity: true)
			}
		}
	}
	
	// MARK: - Segues
	
	func prepareViewController<T : MKAnnotation>(viewController : AnyObject?, forSegue segue : String?, toShowAnnotation annotation : T) {
		
		if let photo = annotation as? Photo {
			if segue! == "Show Photo" || segue == nil {
				if let vc = viewController as? UINavigationController {
					//prepare view controller
					if let ivc = vc.viewControllers[0] as? ImageViewController {
						ivc.imageURL = NSURL(string: photo.imageURL)
						ivc.title = photo.title
					}
				}
			}
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if let apvc = segue.destinationViewController as? AddPhotoViewController {
			apvc.photographerTakingPhoto = self.photographer
		}
		else if let annotation = sender as? MKAnnotationView {
			self.prepareViewController(segue.destinationViewController, forSegue: segue.identifier, toShowAnnotation: annotation.annotation)
		}
	}
	
	@IBAction func addedPhoto(segue : UIStoryboardSegue) {
		if let apvc = segue.sourceViewController as? AddPhotoViewController {
			if let addedPhoto = apvc.addedPhoto {
				self.mapView.addAnnotation(addedPhoto)
				self.mapView.showAnnotations([addedPhoto], animated: true)
				self.photosByPhotographer = nil
			}
		}
		else {
			println("AddPhotoViewController unexpectedly did not add a photo! ")
		}
	}
	
	// MARK: - Initialisation
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
