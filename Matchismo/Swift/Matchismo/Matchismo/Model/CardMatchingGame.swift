//
//  CardMatchingGame.swift
//  Matchismo
//
//  Created by Afonso Graça on 14/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import Foundation

private let costToChoose = 1, mismatchPenalty = 2, matchBonus = 4

class CardMatchingGame: NSObject {
	
	
	private(set) lazy var score = 0
	
	private lazy var cards = [Card]()
	
	init(cardCount: Int, deck : Deck){
		
		super.init()
		
		for index in 0..<cardCount {
			var possibleCard : Card? = deck.drawRandomCard()
			if let card = possibleCard? {
				self.cards += [card]
			}
			else {
				break
			}
		}
	}
	
	func cardAt(index : Int) -> Card? {
		return (index < self.cards.count) ? self.cards[index] : nil
	}
	
	func chooseCardAt(index : Int) {
		
		if let card = self.cardAt(index) as? PlayingCard {
			if !card.matched {
				if card.chosen {
					card.chosen = false
				}
				else {
					for otherCard in self.cards{
						if otherCard.chosen && !otherCard.matched {
							let matchScore = card.match([otherCard])
							if matchScore != 0 {
								self.score += matchScore * matchBonus
								card.matched = true
								otherCard.matched = true
							}
							else {
								otherCard.chosen = false
								self.score -= mismatchPenalty
							}
						}
					}
					card.chosen = true
				}
				self.score -= costToChoose
			}
		}
	}
}