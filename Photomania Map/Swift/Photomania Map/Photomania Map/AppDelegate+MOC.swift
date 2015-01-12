//
//  AppDelegate+MOC.swift
//  Photomania
//
//  Created by Afonso Graça on 10/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import Foundation
import CoreData


extension AppDelegate { //MOC
	
	// MARK: - Core Data
	func saveContext(managedObjectContext : NSManagedObjectContext?) {
		let error = NSErrorPointer()
		if let context = managedObjectContext {
			if context.hasChanges && !context.save(error) {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				NSLog("Unresolved error %@, %@", error.memory!, error.debugDescription)
				abort()
			}
		}
	}
	
	// Returns the managed object context for the application.
	// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
	func createMainQueueManagedObjectContext() -> NSManagedObjectContext? {
		var managedObjectContext : NSManagedObjectContext?
		if let coordinator = self.createPersistentStoreCoordinator() {
			managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
			managedObjectContext?.persistentStoreCoordinator = coordinator
		}
		return managedObjectContext
	}
	
	// Returns the managed object model for the application.
	// If the model doesn't already exist, it is created from the application's model.
	func createManagedObjectModel() -> NSManagedObjectModel? {
		let modelURL = NSBundle.mainBundle().URLForResource("Photomania", withExtension: "momd")
		return NSManagedObjectModel(contentsOfURL: modelURL!)
	}
	
	// Returns the persistent store coordinator for the application.
	// If the coordinator doesn't already exist, it is created and the application's store added to it.
	func createPersistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
		let managedObjectModel = self.createManagedObjectModel()
		let storeURL = self.applicationDocumentsDirectory()?.URLByAppendingPathComponent("MOC.sqlite")
		let error = NSErrorPointer()
		
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
		if persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: error) == nil {
			/*
			Replace this implementation with code to handle the error appropriately.
			
			abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			
			Typical reasons for an error here include:
			* The persistent store is not accessible;
			* The schema for the persistent store is incompatible with current managed object model.
			Check the error message to determine what the actual problem was.
			
			
			If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
			
			If you encounter schema incompatibility errors during development, you can reduce their frequency by:
			* Simply deleting the existing store:
			[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
			
			* Performing automatic lightweight migration by passing the following dictionary as the options parameter:
			@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
			
			Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
			
			*/
			NSLog("Unresolved error %@, %@", error.memory!, error.debugDescription)
			abort();
		}
		return persistentStoreCoordinator;
	}
	
	// Returns the URL to the application's Documents directory
	func applicationDocumentsDirectory() -> NSURL? {
		return NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: nil)
	}
}
