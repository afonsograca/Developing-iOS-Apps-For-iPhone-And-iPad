//
//  PhotosByPhotographerCDTVC.swift
//  Photomania
//
//  Created by Afonso Graça on 16/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class PhotosByPhotographerCDTVC: PhotosCDTVC  {

	var photographer : Photographer?{
		didSet{
			self.title = photographer?.name
			self.setupFetchedResultsController()
		}
	}
	
	func setupFetchedResultsController() {
		
		if let context = self.photographer?.managedObjectContext {
			let request = NSFetchRequest(entityName: "Photo")
			request.predicate = NSPredicate(format: "whoTook = %@", self.photographer!)
			request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true, selector: "localizedStandardCompare:")]
			
			self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
		}
		else {
			self.fetchedResultsController = nil
		}
		
	}

}
