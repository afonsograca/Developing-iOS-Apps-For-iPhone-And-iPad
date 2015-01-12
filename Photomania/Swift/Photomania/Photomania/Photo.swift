//
//  Photo.swift
//  Photomania
//
//  Created by Afonso Graça on 09/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {

    @NSManaged var imageURL: String
    @NSManaged var title: String
    @NSManaged var subtitle: String
    @NSManaged var unique: String
    @NSManaged var whoTook: NSManagedObject

}
