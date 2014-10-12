//
//  Deck.swift
//  Matchismo
//
//  Created by Afonso Graça on 12/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import Foundation

class Deck {
	lazy var cards : [Card] = {
		return [Card]()
	}()
	
	func addCard(card : Card, atTop : Bool = false){
		if atTop {
			self.cards.insert(card, atIndex: 0)
		}
		else {
			self.cards.append(card)
		}
	}
	
	func drawRandomCard() -> Card? {
		var random : Card? = nil
		if !self.cards.isEmpty {
			let index = Int(arc4random_uniform(UInt32(cards.count)))
			random = self.cards[index]
			self.cards.removeAtIndex(index)
		}
		return random
	}
}