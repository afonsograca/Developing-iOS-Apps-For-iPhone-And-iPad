//
//  ViewController.swift
//  Imaginarium
//
//  Created by Afonso Graça on 28/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let ivc = segue.destinationViewController as? ImageViewController {
			ivc.imageURL = NSURL(string: "http://images.apple.com/v/iphone-5s/gallery/a/images/download/\(segue.identifier! ).jpg")
			ivc.title = segue.identifier!
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

