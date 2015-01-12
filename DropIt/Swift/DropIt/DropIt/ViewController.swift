//
//  ViewController.swift
//  DropIt
//
//  Created by Afonso Graça on 23/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDynamicAnimatorDelegate {

	// MARK: Properties
	@IBOutlet weak var gameView: BezierPathView!
	
	var animator :  UIDynamicAnimator!
	var dropItBehaviour : DropItBehaviour!
	var droppingView : UIView?
	var attachment : UIAttachmentBehavior!
	
	var DROP_SIZE : CGSize {
		get { return CGSize(width: self.gameView.bounds.size.width/8, height: self.gameView.bounds.size.width/8) }
	}
	
	// MARK: Gesture Handlers
	@IBAction func tap(sender: UITapGestureRecognizer) {
		self.drop()
	}
	
	@IBAction func pan(sender: UIPanGestureRecognizer) {
		var gesturePoint = sender.locationInView(self.gameView)
		if sender.state == .Began {
			self.attachToDroppingView(gesturePoint)
		} else if sender.state == .Changed {
			self.attachment.anchorPoint = gesturePoint
		} else if sender.state == UIGestureRecognizerState.Ended {
			self.animator.removeBehavior(self.attachment)
			self.gameView.path = nil
		}
		
	}
	// MARK: Movements
	
	func attachToDroppingView( anchorPoint : CGPoint) {
		if let drop = self.droppingView {
			self.attachment = UIAttachmentBehavior(item: drop, attachedToAnchor: anchorPoint)			
			weak var weakSelf = self
			self.attachment.action = {
				let path = UIBezierPath()
				path.moveToPoint(weakSelf!.attachment.anchorPoint)
				path.addLineToPoint(drop.center)
				weakSelf!.gameView.path = path
			}
			self.droppingView = nil
			self.animator.addBehavior(self.attachment)
		}
	}
	func drop() {
		var frame = CGRect(origin: CGPointZero, size: DROP_SIZE)
		
		frame.origin.x = CGFloat((UInt( arc4random_uniform(UInt32(UInt(self.gameView.bounds.size.width))))) / UInt(DROP_SIZE.width)) * DROP_SIZE.width
		
		let dropView = UIView(frame: frame)
		dropView.backgroundColor = self.randomColor()
		
		self.gameView.addSubview(dropView)
		self.droppingView = dropView
		self.dropItBehaviour.add(dropView)
	}
	
	func removeCompletedRows() -> Bool {
		var dropsToRemove = [UIView]()
		for var y = (self.gameView.bounds.size.height - DROP_SIZE.height / CGFloat(2)); y > 0 ; y -= DROP_SIZE.height {
			var rowIsComplete = true
			var dropsFound = [UIView]()
			
			for var x = (DROP_SIZE.width / CGFloat(2)); x <= self.gameView.bounds.size.width - DROP_SIZE.width / CGFloat(2); x += DROP_SIZE.width {
				if let hit = self.gameView.hitTest(CGPointMake(x, y), withEvent: nil) {
					if hit.superview == self.gameView {
						dropsFound.append(hit)
					}
					else {
						rowIsComplete = false
						break
					}
				}
			}
			if dropsFound.count == 0 {
				break
			}
			if rowIsComplete {
				dropsToRemove += dropsFound
			}
		}
		if dropsToRemove.count > 0 {
			for drop in dropsToRemove {
				self.dropItBehaviour.remove(drop)
			}
			self.animateRemovingDrops(dropsToRemove)
		}
		return false
	}
	
	func animateRemovingDrops(dropsToRemove : [UIView]) {
		UIView.animateWithDuration(1.0,
			animations: {
				for drop in dropsToRemove {
					let x = Int(arc4random_uniform(UInt32(self.gameView.bounds.size.width * 5))) - Int(self.gameView.bounds.size.width) * 2
					
					let y = self.gameView.bounds.size.height
					drop.center = CGPointMake(CGFloat(x), -y)
				}
			},
			completion: { (finished: Bool) in
				//dropsToRemove.map { $0.removeFromSuperview()}
				for drop in dropsToRemove {
					drop.removeFromSuperview()
				}
		})
	}
	
	// MARK: Initialisation
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.dropItBehaviour = DropItBehaviour()
		self.animator = UIDynamicAnimator(referenceView: self.gameView)
		self.animator.addBehavior(self.dropItBehaviour)
		self.animator.delegate = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: UIDynamicAnimatorDelegate protocol implementation
	
	func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
		self.removeCompletedRows()
	}
	
	// MARK: Helper Methods
	func randomColor() -> UIColor {
		switch arc4random_uniform(5) {
		case 0 : return UIColor.greenColor()
		case 1 : return UIColor.blueColor()
		case 2 : return UIColor.orangeColor()
		case 3 : return UIColor.redColor()
		case 4 : return UIColor.purpleColor()
		default : return UIColor.blackColor()
		}
	}

}

