//
//  Deck.h
//  Matchismo
//
//  Created by Afonso Graça on 11/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
@interface Deck : NSObject

- (void)addCard: (Card *)card atTop: (BOOL)atTop;
- (void)addCard:(Card *)card;

- (Card *)drawRandomCard;

@end
