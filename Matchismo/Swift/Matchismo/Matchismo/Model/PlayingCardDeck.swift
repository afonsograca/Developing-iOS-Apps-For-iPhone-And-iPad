//
//  PlayingCardDeck.swift
//  Matchismo
//
//  Created by Afonso Graça on 12/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import Foundation

class PlayingCardDeck : Deck {
	override init() {
		super.init()
		for suit in PlayingCard.validSuits() {
			for rank in 1...PlayingCard.maxRank() {
				var card = PlayingCard()
				card.suit = suit
				card.rank = rank
				addCard(card)
			}
		}
	}
}