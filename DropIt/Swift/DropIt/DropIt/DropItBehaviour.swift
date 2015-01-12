//
//  DropItBehaviour.swift
//  DropIt
//
//  Created by Afonso Graça on 24/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class DropItBehaviour: UIDynamicBehavior {
	
	var gravity : UIGravityBehavior
	var collider : UICollisionBehavior
	var animationsOptions : UIDynamicItemBehavior
	
	override init(){
		self.gravity = UIGravityBehavior()
		self.gravity.magnitude = 1.0
		
		self.collider = UICollisionBehavior()
		self.collider.translatesReferenceBoundsIntoBoundary = true
		
		self.animationsOptions = UIDynamicItemBehavior()
		self.animationsOptions.allowsRotation = false
		
		super.init()
		
		self.addChildBehavior(self.gravity)
		self.addChildBehavior(self.collider)
		self.addChildBehavior(self.animationsOptions)
	}
	
	func add<T : UIDynamicItem>(item : T){
		self.gravity.addItem(item)
		self.collider.addItem(item)
		self.animationsOptions.addItem(item)
	}
	
	func remove<T : UIDynamicItem>(item : T) {
		self.gravity.removeItem(item)
		self.collider.removeItem(item)
		self.animationsOptions.removeItem(item)
	}
   
}
