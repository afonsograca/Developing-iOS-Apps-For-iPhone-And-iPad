//
//  ViewController.m
//  Matchismo
//
//  Created by Afonso Graça on 11/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import "ViewController.h"
#import "PlayingCardDeck.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;

@property (nonatomic) int flipsCount;
@property (strong, nonatomic) Deck *deck;
@end

@implementation ViewController

- (Deck *)deck{
	if (!_deck) {
		_deck = [[PlayingCardDeck alloc] init];
	}
	return _deck;
}

- (void)setFlipsCount:(int)flipsCount {
	_flipsCount = flipsCount;
	[self.flipsLabel
	 setText:[NSString stringWithFormat:@"Flips: %d", flipsCount]];
}

- (IBAction)touchCardButton:(UIButton *)sender {
	if ([sender.currentTitle length]) {
		[sender setBackgroundImage:[UIImage imageNamed:@"cardBack"]
						  forState:UIControlStateNormal];
		[sender setTitle:@"" forState:UIControlStateNormal];
	}
	else {
		Card *card = [self.deck drawRandomCard];
		[sender setTitle:card.contents forState:UIControlStateNormal];
		[sender setBackgroundImage:[UIImage imageNamed:@"cardFront"]
						  forState:UIControlStateNormal];
	}
	
	self.flipsCount++;
}


@end
