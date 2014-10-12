//
//  Card.h
//  Matchismo
//
//  Created by Afonso Graça on 11/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property(strong, nonatomic) NSString *contents;

@property(nonatomic, getter=isChosen) BOOL chosen;
@property(nonatomic, getter=isMatched) BOOL matched;

- (int)match: (NSArray *) otherCards;

@end