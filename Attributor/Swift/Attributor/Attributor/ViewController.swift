//
//  ViewController.swift
//  Attributor
//
//  Created by Afonso Graça on 19/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var body: UITextView!
	@IBOutlet weak var outlineButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let title = NSMutableAttributedString(string: self.outlineButton.currentTitle!)
		title.setAttributes([NSStrokeWidthAttributeName : 3, NSStrokeColorAttributeName : self.outlineButton.tintColor!], range: NSRange(location: 0, length: title.length))
		self.outlineButton.setAttributedTitle(title, forState: .Normal)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.usePreferredFonts()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferredFontsChanged:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
		
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "Analyse Text" {
			let view : TextStatsViewController = segue.destinationViewController as TextStatsViewController
			view.textToAnalyse = self.body.textStorage
		}
	}
	
	func preferredFontsChanged(notification : NSNotification){
		self.usePreferredFonts()
	}
	
	func usePreferredFonts() {
		self.body.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
	}
	
	@IBAction func changeBodySelectionToMatchButtonBackground(sender: UIButton) {
	
		self.body.textStorage.addAttribute(NSForegroundColorAttributeName, value: sender.backgroundColor!, range: self.body.selectedRange)
	}
	
	@IBAction func outlineTextSelection() {
		self.body.textStorage.addAttributes([NSStrokeWidthAttributeName : -3, NSStrokeColorAttributeName : UIColor.blackColor()], range: self.body.selectedRange)
	}
	
	@IBAction func unoutlineTextSelection() {
		self.body.textStorage.removeAttribute(NSStrokeWidthAttributeName, range: self.body.selectedRange)
	}
}

