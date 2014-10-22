//
//  ViewController.m
//  Attributor
//
//  Created by Afonso Graça on 22/10/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

#import "ViewController.h"
#import "TextStatsViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *outlineButton;
@property (weak, nonatomic) IBOutlet UITextView *body;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self setupOutlineButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self usePreferredFonts];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredFontsChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Analyse Text"]) {
		TextStatsViewController *view = (TextStatsViewController *) segue.destinationViewController;
		view.textToAnalyse = self.body.textStorage;
	}
	
}

- (void)setupOutlineButton {
	[self.outlineButton setAttributedTitle: [[NSAttributedString alloc] initWithString:self.outlineButton.currentTitle attributes:@{NSStrokeWidthAttributeName : @3, NSStrokeColorAttributeName : [self.outlineButton tintColor]}] forState:UIControlStateNormal];
}

- (void)preferredFontsChanged: (NSNotification *)notification {
	[self usePreferredFonts];
}

- (void)usePreferredFonts {
	self.body.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (IBAction)changeBodySelectionToMatchButtonBackground:(UIButton *)sender {
	[self.body.textStorage addAttribute:NSForegroundColorAttributeName value:sender.backgroundColor range:self.body.selectedRange];
}

- (IBAction)outlineTextSelection {
	[self.body.textStorage addAttribute:NSStrokeWidthAttributeName value:@-3 range:self.body.selectedRange];
}

- (IBAction)unoutlineTextSelection {
	[self.body.textStorage removeAttribute:NSStrokeWidthAttributeName range:self.body.selectedRange];
}
@end
