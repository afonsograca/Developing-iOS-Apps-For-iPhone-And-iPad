//
//  ViewController.swift
//  SuperCard
//
//  Created by Afonso Graça on 22/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var playingCardView: PlayingCardView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.playingCardView.rank =  13
		self.playingCardView.suit = "♥️"
		
		self.playingCardView.addGestureRecognizer(UIPinchGestureRecognizer(target: self.playingCardView, action: "pinch:"))
	}

	@IBAction func swipe(sender: UISwipeGestureRecognizer) {
		self.playingCardView.faceUp = !self.playingCardView.faceUp
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

