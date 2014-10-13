//
//  PlayingCard.m
//  Matchismo
//
//  Created by Afonso Graça on 11/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

- (int)match:(NSArray *)otherCards {
	int score = 0;
	
	if ([otherCards count] == 1) {
		PlayingCard *otherCard = [otherCards firstObject];
		
		if ([otherCard.suit isEqualToString: self.suit]) {
			score += 1;
		}
		else if (otherCard.rank == self.rank) {
			score += 4;
		}
	}
	return score;
}

+ (NSArray *)validSuits {
	return @[@"♠︎",@"♦︎",@"♣︎",@"♥︎"];
}

+ (NSArray *)rankStrings {
	return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+ (NSUInteger)maxRank {
	return [[self rankStrings] count]-1;
}

@synthesize suit = _suit;

- (void)setSuit: (NSString *)suit {
	if ([[PlayingCard validSuits] containsObject:suit]) {
		_suit = suit;
	}
}

- (NSString *)suit {
	return _suit ? _suit : @"?";
}

- (void)setRank:(NSUInteger)rank{
	if (rank <= [PlayingCard maxRank]) {
		_rank = rank;
	}
}

- (NSString *)contents {
	NSArray *rankStrings = [PlayingCard rankStrings];
	return [rankStrings[self.rank] stringByAppendingString:self.suit];
}

@end
