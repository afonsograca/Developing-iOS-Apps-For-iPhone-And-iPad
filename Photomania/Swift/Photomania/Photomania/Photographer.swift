//
//  Photographer.swift
//  Photomania
//
//  Created by Afonso Graça on 09/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import Foundation
import CoreData

class Photographer: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var photos: NSSet

}
