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
	
	lazy var game : CardMatchingGame = CardMatchingGame(cardCount: self.cardButtons.count, deck: self.createDeck())
	
	func createDeck() -> Deck {
		return PlayingCardDeck()
	}
	
	@IBAction func touchCardButton(sender: UIButton) {
		let chosenButtonIndex = find(self.cardButtons, sender)
		self.game.chooseCardAt(chosenButtonIndex!)
		
		self.updateUI()
	}
	
	func updateUI() {
		for cardButton in self.cardButtons {
			let chosenButtonIndex = find(self.cardButtons, cardButton)
			let card = self.game.cardAt(chosenButtonIndex!)
			
			cardButton.setTitle(self.titleForCard(card!), forState: .Normal)
			cardButton.setBackgroundImage(self.backgroundImageForCard(card!), forState: .Normal)
			cardButton.enabled = !card!.matched
		}
		
	}
	
	func titleForCard(card : Card) -> String {
		return card.chosen ? card.contents : ""
	}
	
	func backgroundImageForCard(card : Card) -> UIImage {
		return UIImage(named: card.chosen ? "cardFront" : "cardBack")
	}

}

