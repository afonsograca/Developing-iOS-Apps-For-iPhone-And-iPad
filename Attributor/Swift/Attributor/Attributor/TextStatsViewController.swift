//
//  TextStatsViewController.swift
//  Attributor
//
//  Created by Afonso Graça on 20/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class TextStatsViewController : UIViewController {
	
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		self.textToAnalyse = NSAttributedString(string: "test", attributes: [NSForegroundColorAttributeName : UIColor.greenColor(), NSStrokeWidthAttributeName : -3])
//	}
	
	var textToAnalyse : NSAttributedString = NSAttributedString() {
		didSet {
			if self.view.window != nil {self.updateUI()}
		}
	}
	
	@IBOutlet weak var colourfulCharacterLabel: UILabel!
	@IBOutlet weak var outlinedCharactersLabel: UILabel!
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.updateUI()
	}
	
	func updateUI() {
		self.colourfulCharacterLabel.text = "\(self.charactersWith(NSForegroundColorAttributeName).length) colourful characters"
		self.outlinedCharactersLabel.text = "\(self.charactersWith(NSStrokeWidthAttributeName).length) outlined characters"
	}
	
	func charactersWith(attribute : String) -> NSAttributedString {
		var characters = NSMutableAttributedString()
		
		var index = 0;
		while index < self.textToAnalyse.length {
			var range = NSRange(location: 0,length: 1)
			var value : AnyObject? = self.textToAnalyse.attribute(attribute, atIndex: index, effectiveRange: &range)
			if value != nil {
				characters.appendAttributedString(self.textToAnalyse.attributedSubstringFromRange(range))
				index = range.location + range.length
			}
			else {
				index++
			}
		}
		
		return characters
	}
	
}
