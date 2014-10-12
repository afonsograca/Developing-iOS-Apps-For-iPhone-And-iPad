//
//  PlayingCard.h
//  Matchismo
//
//  Created by Afonso Graça on 11/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import "Card.h"

@interface PlayingCard : Card

@property(strong, nonatomic) NSString *suit;
@property(nonatomic) NSUInteger rank;

+ (NSArray *)validSuits;
+ (NSUInteger)maxRank;

@end
