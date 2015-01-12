//
//  PhotographersCDTVC.swift
//  Photomania
//
//  Created by Afonso Graça on 10/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit
import CoreData

class PhotographersCDTVC: CoreDataTableViewController {
	
	override func awakeFromNib() {
		NSNotificationCenter.defaultCenter().addObserverForName(PhotoDatabaseAvailabilityNotification, object: nil, queue: nil) { (note : NSNotification!) -> Void in
			self.managedObjectContext = note.userInfo![PhotoDatabaseAvailabilityContext] as? NSManagedObjectContext
		}
	}

	var managedObjectContext : NSManagedObjectContext? {
		didSet {
			let request = NSFetchRequest(entityName: "Photographer")
			request.predicate = nil
			request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: "localizedStandardCompare:")]
			
			
			self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
		}
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCellWithIdentifier("Photographer Cell") as UITableViewCell
		let photographer = self.fetchedResultsController.objectAtIndexPath(indexPath) as Photographer
		
		cell.textLabel?.text = photographer.name
		cell.detailTextLabel?.text = "\(photographer.photos.count) photos"
		
		return cell
	}
	
	
	// MARK: - Navigation
	
	func prepareViewController(viewController : AnyObject?, forSegue segue : String?, fromIndexPath indexPath : NSIndexPath) {
		
		let photographer : Photographer = self.fetchedResultsController.objectAtIndexPath(indexPath) as Photographer
		if let vc = viewController as? PhotosByPhotographerCDTVC {
			vc.photographer = photographer
		}
		else if let vc = viewController as? PhotosByPhotographerMapViewController {
			vc.photographer = photographer
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		var indexPath : NSIndexPath? = nil
		if let cell = sender as? UITableViewCell {
			indexPath = self.tableView.indexPathForCell(cell)
		}
		self.prepareViewController(segue.destinationViewController, forSegue: segue.identifier!, fromIndexPath: indexPath!)
	}
	
	override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		
		var detailvc: AnyObject? = self.splitViewController?.viewControllers.last
		if let navigation = detailvc as? UINavigationController {
			detailvc = navigation.viewControllers.first
			
			self.prepareViewController(detailvc, forSegue: "", fromIndexPath: indexPath)
		}
	}
}
