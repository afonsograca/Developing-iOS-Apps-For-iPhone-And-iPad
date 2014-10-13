//
//  ViewController.swift
//  Matchismo
//
//  Created by Afonso Graça on 12/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet var cardButtons: [UIButton]!
	
	lazy var deck : Deck = PlayingCardDeck()
	
	@IBAction func touchCardButton(sender: UIButton) {
		if sender.currentTitle == nil {
			sender.setTitle("", forState: .Normal)
		}
		if sender.currentTitle!.isEmpty {
			let card = self.deck.drawRandomCard()
			
			sender.setBackgroundImage(UIImage(named: "cardFront"),
				forState: .Normal)
			sender.setTitle(card!.contents, forState: .Normal)
		}
		else {
			sender.setBackgroundImage(UIImage(named: "cardBack"),
				forState: UIControlState.Normal)
			sender.setTitle("", forState: .Normal)
		}
	}

}

