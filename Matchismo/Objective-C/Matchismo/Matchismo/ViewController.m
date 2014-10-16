//
//  ViewController.m
//  Matchismo
//
//  Created by Afonso Graça on 11/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import "ViewController.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (strong, nonatomic) CardMatchingGame *game;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gameModeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *playLabel;

@end

@implementation ViewController

- (CardMatchingGame *)game {
	if (!_game) {
		_game = [[CardMatchingGame alloc]
					initWithCardCount: [self.cardButtons count]
							usingDeck: [self createDeck]];
	}
	return _game;
}

- (Deck *)createDeck {
	return [[PlayingCardDeck alloc] init];
}

- (IBAction)touchCardButton:(UIButton *)sender {
	self.gameModeSwitch.enabled = false;
	NSUInteger chosenButtonIndex = [self.cardButtons indexOfObject:sender];
	[self.game chooseCardAtIndex:chosenButtonIndex];
	
	[self updateUI];
}

- (IBAction)touchReDeal:(UIButton *)sender {
	self.gameModeSwitch.enabled = true;
	_game = [[CardMatchingGame alloc] initWithCardCount:[self.cardButtons count]
											 usingDeck: [self createDeck]];
	[self updateUI];
}

- (IBAction)touchGameModeSwitch:(UISegmentedControl *)sender {
}


- (void)updateUI {
	for (UIButton *cardButton in self.cardButtons) {
		NSUInteger cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
		Card *card = [self.game cardAtIndex:cardButtonIndex];
		
		[cardButton setTitle:[self titleForCard:card]
					forState:UIControlStateNormal];
		[cardButton setBackgroundImage:[self backgroundImageForCard:card]
							  forState:UIControlStateNormal];
		cardButton.enabled = !card.isMatched;
	}
	self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)self.game.score];
}

- (NSString *)titleForCard: (Card *)card {
	return card.isChosen ? card.contents : @"";
}

- (UIImage * )backgroundImageForCard: (Card *) card {
	return [UIImage imageNamed: card.isChosen ? @"cardFront" : @"cardBack"];
}

@end
