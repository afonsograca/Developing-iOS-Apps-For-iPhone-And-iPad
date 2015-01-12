//
//  BezierPathView.swift
//  DropIt
//
//  Created by Afonso Graça on 25/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class BezierPathView: UIView {
	
	var path : UIBezierPath? {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
		if let path = self.path {
			path.stroke()
		}
    }
}
