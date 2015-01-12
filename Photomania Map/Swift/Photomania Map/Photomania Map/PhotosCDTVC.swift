//
//  PhotosCDTVC.swift
//  Photomania
//  Hook up fetchedResultsController to any Photo Fetch Request
//  Use "Photo Cell" as your table view cell's reuse object
//
//  Created by Afonso Graça on 17/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit



class PhotosCDTVC: CoreDataTableViewController {

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCellWithIdentifier("Photo Cell") as? UITableViewCell
		let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Photo
		
		cell?.textLabel?.text = photo?.title
		cell?.detailTextLabel?.text = photo?.subtitle
		
		return cell!
	}
	
	// MARK: - Navigation
	
	func prepareViewController(viewController : AnyObject?, forSegue segue : String?, fromIndexPath indexPath : NSIndexPath) {
		
		let photo : Photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as Photo
		if let vc = viewController as? UINavigationController {
			if segue! == "Display Photo" || segue == nil {
				//prepare view controller
				if let ivc = vc.viewControllers[0] as? ImageViewController {
					ivc.imageURL = NSURL(string: photo.imageURL)
					ivc.title = photo.title
				}
			}
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
