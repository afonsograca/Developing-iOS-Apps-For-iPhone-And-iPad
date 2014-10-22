//
//  CardMatchingGame.h
//  Matchismo
//
//  Created by Afonso Graça on 13/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"
#import "Card.h"

@interface CardMatchingGame : NSObject

//designated initialiser
- (instancetype)initWithCardCount: (NSInteger)count
						usingDeck: (Deck *)deck;

- (void)chooseCardAtIndex: (NSInteger)index;
- (Card *)cardAtIndex: (NSUInteger)index;

@property (nonatomic, readonly) NSInteger score;
@property (nonatomic) NSInteger noCardsToMatch;
@property (nonatomic, strong) NSString *resultString;

@end
