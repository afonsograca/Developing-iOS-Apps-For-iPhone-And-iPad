//
//  Photo+Flickr.swift
//  Photomania
//
//  Created by Afonso Graça on 09/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import CoreData

extension Photo { // Flickr
	class func photoWithFlickrInfo(dictionary : [String : AnyObject], context : NSManagedObjectContext) -> Photo? {
		
		var photo : Photo?
		
		let unique = dictionary[FLICKR_PHOTO_ID] as String
		
		let request = NSFetchRequest(entityName: "Photo")
		request.predicate = NSPredicate(format: "unique = %@", unique)
		
		let error = NSErrorPointer()
		let matches = context.executeFetchRequest(request, error: error)
		
		if matches == nil || error != nil || matches?.count > 1 {
			//handle error
		}
		else if matches?.count > 0{
			photo = matches?.first as? Photo
		}
		else {
			photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as? Photo
			photo?.unique = unique
			photo?.title = (dictionary as AnyObject).valueForKeyPath(FLICKR_PHOTO_TITLE) as String
			photo?.subtitle = (dictionary as AnyObject).valueForKeyPath(FLICKR_PHOTO_DESCRIPTION) as String
			photo?.imageURL = FlickrFetcher.URLforPhoto(dictionary, format: FlickrPhotoFormatLarge).absoluteString!
			photo?.latitude = dictionary[FLICKR_LATITUDE] as Double
			photo?.longitude = dictionary[FLICKR_LONGITUDE] as Double
			photo?.thumbnailURL = FlickrFetcher.URLforPhoto(dictionary, format: FlickrPhotoFormatSquare).absoluteString!
			
			let photographerName = (dictionary as AnyObject).valueForKeyPath(FLICKR_PHOTO_OWNER) as String
			photo?.whoTook = Photographer.photographer(photographerName, context: context)!
		}
		return photo
	}
	
	class func loadPhotosFromFlickr(array:[[String : AnyObject]], context: NSManagedObjectContext) {
		for currentPhoto in array {
			self.photoWithFlickrInfo(currentPhoto, context: context)
		}
	}
}