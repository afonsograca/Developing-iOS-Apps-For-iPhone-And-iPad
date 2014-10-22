//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Afonso Graça on 13/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame ()

@property (nonatomic, readwrite) NSInteger score;
@property (nonatomic, strong) NSMutableArray *cards; //of Card

@end

@implementation CardMatchingGame

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;

- (NSInteger)noCardsToMatch {
	if (!_noCardsToMatch) {
		_noCardsToMatch = 1;
	}
	return _noCardsToMatch;
}

- (NSString *)resultString {
	if (!_resultString) {
		_resultString = @"";
	}
	return _resultString;
}

- (NSMutableArray *)cards {
	if (!_cards) {
		_cards = [[NSMutableArray alloc] init];
	}
	return _cards;
}

- (instancetype)initWithCardCount:(NSInteger)count usingDeck:(Deck *)deck {
	
	self = [super init];
	
	if (self) {
		for (int i = 0; i < count; i++) {
			Card *card = [deck drawRandomCard];
			if (card) {
				[self.cards addObject: card];
			}
			else {
				self = nil;
				break;
			}
		}
	}
	return self;
}

- (void)chooseCardAtIndex:(NSInteger)index {
	Card *card = [self cardAtIndex: index];
	self.resultString = card.contents;
	
	if (!card.isMatched) {
		if (card.isChosen) {
			card.chosen = NO;
			self.resultString = @"";
		}
		else {
			
			NSMutableArray *otherCards = [[NSMutableArray alloc] init];
			//match against other cards
			for (Card *otherCard in self.cards) {
				if (otherCard.isChosen && !otherCard.isMatched) {
					[otherCards addObject:otherCard];
				}
				if ([otherCards count] == self.noCardsToMatch) {
					int matchScore = [card match:otherCards];
					
					NSString *otherCardsContents = @"";
					for (Card *otherCardContent in otherCards) {
						otherCardsContents = [otherCardsContents stringByAppendingString:otherCardContent.contents];
					}
					
					if (matchScore) {
						self.score += matchScore * MATCH_BONUS;
						card.matched = YES;
						for (Card *otherCardMatched in otherCards) {
							otherCardMatched.matched = YES;
						}
						
						self.resultString = [NSString stringWithFormat:@"Matched %@ %@ for %d points.", card.contents, otherCardsContents, matchScore * MATCH_BONUS];
					}
					else {
						self.score -= MISMATCH_PENALTY;
						for (Card *otherCardFailed in otherCards) {
							otherCardFailed.chosen = NO;
						}
						self.resultString = [NSString stringWithFormat:@"%@ %@ don't match! %d point penalty!", card.contents, otherCardsContents, MISMATCH_PENALTY];
					}
					break;
				}
			}
			card.chosen = YES;
		}
		self.score -= COST_TO_CHOOSE;
	}
	
}

- (Card *)cardAtIndex:(NSUInteger)index {
	return (index < [self.cards count]) ? self.cards[index] : nil;
}


@end
