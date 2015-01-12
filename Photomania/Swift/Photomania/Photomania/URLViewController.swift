//
//  URLViewController.swift
//  Photomania
//
//  Created by Afonso Graça on 19/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class URLViewController: UIViewController {
	
	var url : NSURL? {
		didSet {
			self.updateUI()
		}
	}

	@IBOutlet weak var urlTextView: UITextView!
	 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.updateUI()
    }

	func updateUI() {
		if let textView = self.urlTextView {
			if let url = self.url {
				textView.text = url.absoluteString
			}
		}
	}
}
