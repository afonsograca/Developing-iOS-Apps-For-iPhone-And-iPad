//
//  Photographer+Create.swift
//  Photomania
//
//  Created by Afonso Graça on 09/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import CoreData

extension Photographer {
	
	class func photographer(name: String, context: NSManagedObjectContext) -> Photographer? {
		var photographer: Photographer?
		
		if !name.isEmpty {
			let request = NSFetchRequest(entityName: "Photographer")
			request.predicate = NSPredicate(format: "name = %@", name)
			
			let error = NSErrorPointer()
			let matches = context.executeFetchRequest(request, error: error)
			
			if matches == nil || error != nil || matches?.count > 1 {
				//handle error
			}
			else if matches?.count > 0{
				photographer = matches?.last as? Photographer
			}
			else {
				photographer = NSEntityDescription.insertNewObjectForEntityForName("Photographer", inManagedObjectContext: context) as? Photographer
				photographer?.name = name
			}
		}
		return photographer
	}
}