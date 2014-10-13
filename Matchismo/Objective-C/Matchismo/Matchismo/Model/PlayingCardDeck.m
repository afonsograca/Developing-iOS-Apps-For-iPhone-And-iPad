//
//  PlayingCardDeck.m
//  Matchismo
//
//  Created by Afonso Graça on 11/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@implementation PlayingCardDeck

- (instancetype)init {
	self = [super init];
	if (self) {
		for (NSString *suit in [PlayingCard validSuits]) {
			for (NSUInteger i = 1; i <= [PlayingCard maxRank]; i++) {
				PlayingCard *card = [[PlayingCard alloc] init];
				card.suit = suit;
				card.rank = i;
				[self addCard:card];
			}
		}
	}
	return self;
}

@end
