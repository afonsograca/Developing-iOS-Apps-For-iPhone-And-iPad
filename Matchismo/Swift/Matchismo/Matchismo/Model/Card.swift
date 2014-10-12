//
//  Card.swift
//  Matchismo
//
//  Created by Afonso Graça on 12/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import Foundation

class Card : NSObject {
	var chosen = false, matched = false
	var contents : String { return "" }

	func match(otherCards : [Card]) -> Int {
		var score = 0
		for card in otherCards {
			if card.contents == self.contents {
				score = 1
			}
		}
		return score
	}
}