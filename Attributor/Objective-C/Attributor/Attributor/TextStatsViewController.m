//
//  TextStatsViewController.m
//  Attributor
//
//  Created by Afonso Graça on 22/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import "TextStatsViewController.h"

@interface TextStatsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *colourfulCharacterLabel;
@property (weak, nonatomic) IBOutlet UILabel *outlinedCharacterLabel;

@end

@implementation TextStatsViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//	self.textToAnalyse = [[NSAttributedString alloc] initWithString:@"test" attributes:@{NSForegroundColorAttributeName : [UIColor greenColor], NSStrokeWidthAttributeName : @-3}];
//}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updateUI];
}

- (void)updateUI {
	self.colourfulCharacterLabel.text = [NSString stringWithFormat:@"%lu colourful characters", (unsigned long)[[self charactersWithAttribute: NSForegroundColorAttributeName] length]];
	self.outlinedCharacterLabel.text = [NSString stringWithFormat:@"%lu outlined characters", (unsigned long)[[self charactersWithAttribute: NSStrokeWidthAttributeName] length]];
}

- (NSAttributedString *)charactersWithAttribute: (NSString *)attribute {
	NSMutableAttributedString *characters = [[NSMutableAttributedString alloc] init];
	
	int index = 0;
	
	while(index < [self.textToAnalyse length]){
		NSRange range;
		id value = [self.textToAnalyse attribute:attribute atIndex:index effectiveRange:&range];
		if (value) {
			[characters appendAttributedString:[self.textToAnalyse attributedSubstringFromRange:range]];
			index =  (int)(range.location + range.length);
		}
		else {
			index++;
		}
	}
	return characters;
}

@end
