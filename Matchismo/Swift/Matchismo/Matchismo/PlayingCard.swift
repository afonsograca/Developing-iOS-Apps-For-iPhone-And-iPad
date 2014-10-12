//
//  PlayingCard.swift
//  Matchismo
//
//  Created by Afonso Graça on 12/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import Foundation

class PlayingCard: Card {
	var rank : Int = 0 {
		didSet {
			if self.rank > PlayingCard.maxRank() {
				self.rank = 0
			}
		}
	}
	
	var suit : String = "?" {
		didSet {
			if !contains(PlayingCard.validSuits(), self.suit) {
				self.suit = "?"
			}
		}
	}
	
	override var contents : String {
		return "\(PlayingCard.rankStrings()[rank])\(suit)"
	}
	
	class func validSuits() -> [String] {
		return ["♠︎","♦︎","♣︎","♥︎"]
	}
	class func rankStrings() -> [String] {
		return ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
	}
	class func maxRank() -> Int {
		return PlayingCard.rankStrings().count - 1
	}
}