//
//  PlayingCardView.swift
//  SuperCard
//
//  Created by Afonso Graça on 22/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {
	
	// MARK: Properties
	var rank : Int = 0 {
		didSet { self.setNeedsDisplay() }
	}
	var suit : String = "" {
		didSet { self.setNeedsDisplay() }
	}
	var faceUp : Bool = false {
		didSet { self.setNeedsDisplay() }
	}
	
	func rankAsString() -> String {
		return ["?","A","2","3","4","5","6","7","8","9","10","J","Q","K"][self.rank]
	}
	
	// MARK: Drawing
	
	let CORNER_FONT_STANDARD_HEIGHT : CGFloat = 180.0;
	let CORNER_RADIUS : CGFloat = 12.0;
	
	var faceCardScaleFactor : CGFloat = 0.90 {
		didSet{ self.setNeedsDisplay() }
	}
	
	func cornerScaleFactor () -> CGFloat { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT }
	func cornerRadius() -> CGFloat { return CORNER_RADIUS * self.cornerScaleFactor() }
	func cornerOffset() -> CGFloat { return self.cornerRadius() / 3.0 }
	
	func drawCorners() {
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .Center
		
		let cornerFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody).fontWithSize(UIFont.preferredFontForTextStyle(UIFontTextStyleBody).pointSize * self.cornerScaleFactor())
		
		let cornerText = NSAttributedString(string: "\(self.rankAsString())\n\(self.suit)", attributes: [NSFontAttributeName : cornerFont , NSParagraphStyleAttributeName : paragraphStyle])
		
		let textBounds = CGRect(origin: CGPointMake(self.cornerOffset(), self.cornerOffset()), size: cornerText.size())
		cornerText.drawInRect(textBounds)
		
		let context = UIGraphicsGetCurrentContext()
		CGContextTranslateCTM(context, self.bounds.size.width, self.bounds.size.height)
		CGContextRotateCTM(context, CGFloat(M_PI))
		cornerText.drawInRect(textBounds)
	}
	
	func drawPips() {
	
	}
	
	// MARK: Gestures
	
	func pinch(gesture: UIPinchGestureRecognizer) {
		if gesture.state == .Changed || gesture.state == .Ended {
			self.faceCardScaleFactor *= gesture.scale
			gesture.scale = 1.0;
		}
	}
	
	// MARK: Initialisation
	func setup() {
		self.opaque = false
		self.backgroundColor = nil
		self.contentMode = .Redraw
	}
	
	override func awakeFromNib() {
		self.setup()
	}
	// Only override drawRect: if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func drawRect(rect: CGRect) {
	// Drawing code
		let roundedRect = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius())
		roundedRect.addClip()
		
		UIColor.whiteColor().setFill()
		UIRectFill(self.bounds)
		
		UIColor.blackColor().setStroke()
		roundedRect.stroke()
		
		if self.faceUp {
			let faceImage = UIImage(named: "\(self.rankAsString())\(self.suit)")
			if let image = faceImage {
				image.drawInRect(CGRectInset(self.bounds,
					self.bounds.size.width * (1.0 - self.faceCardScaleFactor),
					self.bounds.height * (1.0 - self.faceCardScaleFactor)))
			}
			else {
				self.drawPips()
			}
			
			self.drawCorners()
		}
		else {
			if let cardback = UIImage(named: "cardBack") {
					cardback.drawInRect(self.bounds)
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
 
}
