//
//  ViewController.swift
//  Bouncer
//
//  Created by Afonso Graça on 02/12/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, UIAlertViewDelegate {

	let blockSize : CGSize = CGSizeMake(40, 40)
	weak var redBlock : UIView?
	weak var blackBlock : UIView?
	var animator : UIDynamicAnimator!
	var gravity : UIGravityBehavior!
	var collider : UICollisionBehavior!
	var elastic : UIDynamicItemBehavior!
	var quicksand : UIDynamicItemBehavior!
	var motionManager : CMMotionManager!
	// scoring properties
	weak var scoreLabel : UILabel?
	lazy var lastScore : Double = 0
	lazy var maxScore : Double = 0
	lazy var blackBlockDistanceTraveled : Double = 0
	var lastRecordedBlackBlockTravelTime : NSDate?
	lazy var cumulativeBlackBlockTravelTime : Double = 0
	var blackBlockTracker : UIDynamicItemBehavior!
	var scoreBoundary : UICollisionBehavior!
	var scoreBoundaryCenter : CGPoint?
	
	// MARK: - Game Parts Creation
	
	func addBlockOffsetFromCenterBy(offset : UIOffset) -> UIView? {
		
		let blockCenter : CGPoint = CGPointMake(CGRectGetMidX(self.view.bounds) + offset.horizontal, CGRectGetMidY(self.view.bounds) + offset.vertical)
		
		let blockFrame = CGRectMake(blockCenter.x - blockSize.width/2, blockCenter.y - blockSize.height/2, blockSize.width, blockSize.height)
		
		let block = UIView(frame: blockFrame)
		self.view.addSubview(block)
		
		return block
	}
	
	func resetElasticity() {
		
		if let elasticity = NSUserDefaults.standardUserDefaults().valueForKey("Settings_Elasticity") as? NSNumber {
			self.elastic.elasticity = elasticity as CGFloat
		}
		else {
			self.elasti c.elasticity = 1.0
		}
	}
	
	
	func initialiseAnimators(){
		self.animator = UIDynamicAnimator(referenceView: self.view)
		self.gravity = UIGravityBehavior()
		self.collider = UICollisionBehavior()
		self.collider.translatesReferenceBoundsIntoBoundary = true
		self.elastic = UIDynamicItemBehavior()
		self.resetElasticity()
		self.quicksand = UIDynamicItemBehavior()
		self.quicksand.resistance = 0
		self.motionManager = CMMotionManager()
		self.motionManager.accelerometerUpdateInterval = 0.1
		
		addBehavioursTo(self.animator, behaviours: [self.gravity, self.collider, self.elastic, self.quicksand])
	}
	
	// MARK: - Game Engine
	
	func pauseGame() {
		self.motionManager.stopAccelerometerUpdates()
		self.gravity.gravityDirection = CGVectorMake(0, 0)
		self.quicksand.resistance = 10.0
		self.pauseScoring()
	}
	
	func isPaused() -> Bool {
		return !self.motionManager.accelerometerActive
	}
	
	func resumeGame() {
		
		if self.scoreLabel == nil { self.setScoreLabel() }
		
		if self.redBlock == nil {
			self.redBlock = self.addBlockOffsetFromCenterBy(UIOffsetMake(-100.0, 0.0))
			self.redBlock?.backgroundColor = UIColor.redColor()
			self.gravity.addItem(redBlock!)
			self.collider.addItem(redBlock!)
			self.elastic.addItem(redBlock!)
			self.quicksand.addItem(redBlock!)
			
			self.blackBlock = self.addBlockOffsetFromCenterBy(UIOffsetMake(100.0, 0.0))
			self.blackBlock?.backgroundColor = UIColor.blackColor()
			self.collider.addItem(blackBlock!)
			self.quicksand.addItem(blackBlock!)
		}
		
		self.quicksand.resistance = 0
		self.gravity.gravityDirection = CGVectorMake(0, 0)
		
		if !self.motionManager.accelerometerActive {
			self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) { (accelerometerData : CMAccelerometerData!, error : NSError!) -> Void in
				let x  = CGFloat(accelerometerData.acceleration.x)
				let y  = CGFloat(accelerometerData.acceleration.y)
				
				switch (UIApplication.sharedApplication().statusBarOrientation) {
				case .LandscapeRight:
					self.gravity.gravityDirection = CGVectorMake(-y, -x)
				case .LandscapeLeft:
					self.gravity.gravityDirection = CGVectorMake(y, x)
				case .Portrait:
					self.gravity.gravityDirection = CGVectorMake(x, -y)
				case .PortraitUpsideDown:
					self.gravity.gravityDirection = CGVectorMake(-x, y)
				default:
					self.gravity.gravityDirection = CGVectorMake(0, 0)
				}
				
				self.updateScore()
			}
		}
	}
	
	func restartGame() {
		self.animator = nil
		self.motionManager = nil
		self.redBlock?.removeFromSuperview()
		self.blackBlock?.removeFromSuperview()
		self.resetScore()
		if self.view.window != nil {
			self.initialiseAnimators()
			self.resumeGame()
		}
	}
	
	// MARK: - Animator methods
	
	func addBehavioursTo(animator: UIDynamicAnimator, behaviours : [UIDynamicBehavior!]) {
		for behaviour in behaviours {
			animator.addBehavior(behaviour)
		}
	}

	// MARK: - View Controller Lifecycle
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		self.resumeGame()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.pauseGame()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.initialiseAnimators()
		
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tap"))
			
		let doubleTap = UITapGestureRecognizer(target: self, action: "doubleTap")
		doubleTap.numberOfTapsRequired = 2
		
		self.view.addGestureRecognizer(doubleTap)
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil) { (note:NSNotification!) -> Void in
			self.pauseGame()
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { (note:NSNotification!) -> Void in
			// only resume if we regain active and this VC is on screen at the time
			if self.view.window != nil { self.resumeGame() }
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(NSUserDefaultsDidChangeNotification, object: nil, queue: nil) { (notification:NSNotification!) -> Void in
			self.resetElasticity()
		}
	}
	
	
	@IBAction func tap() {
		isPaused() ? self.resumeGame() : self.pauseGame()
	}
	
	@IBAction func doubleTap() {
		if !isPaused() { self.pauseGame() }
		UIAlertView(title: "Bouncer", message: "Restart Game?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes").show()
	}
	
	// MARK: - Scorekeeping methods
	/* TODO:
	func updateScore() {
		if let lastRecordedTravelTime = self.lastRecordedBlackBlockTravelTime {
			self.cumulativeBlackBlockTravelTime -= lastRecordedTravelTime.timeIntervalSinceNow
			
			var score = self.blackBlockDistanceTraveled / self.cumulativeBlackBlockTravelTime
			if score > self.maxScore { self.maxScore = score}
			
			if (score != self.lastScore) || self.scoreLabel == nil {
				
			}
		}
	}
	- (void)updateScore
	{
	if (self.lastRecordedBlackBlockTravelTime) {
	self.cumulativeBlackBlockTravelTime -= [self.lastRecordedBlackBlockTravelTime timeIntervalSinceNow];
	double score = self.blackBlockDistanceTraveled / self.cumulativeBlackBlockTravelTime;
	if (score > self.maxScore) self.maxScore = score;
	if ((score != self.lastScore) || ![self.scoreLabel.text length]) {
	self.scoreLabel.textColor = [UIColor blackColor];
	self.scoreLabel.text = [NSString stringWithFormat:@"%.0f\n%.0f", score, self.maxScore];
	[self updateScoreBoundary];
	} else if (!CGPointEqualToPoint(self.scoreLabel.center, self.scoreBoundaryCenter)) {
	[self updateScoreBoundary];
	}
	} else {
	[self.animator addBehavior:self.blackBlockTracker];
	self.scoreLabel.text = nil;
	}
	self.lastRecordedBlackBlockTravelTime = [NSDate date];
	}
	
	func pauseScoring() {
		self.lastRecordedBlackBlockTravelTime = nil
		self.scoreLabel?.text = "Paused"
		self.scoreLabel?.textColor = UIColor.lightGrayColor()
		self.animator.removeBehavior(self.blackBlockTracker)
	}
	
	func resetScore() {
		self.blackBlockDistanceTraveled = 0;
		self.lastRecordedBlackBlockTravelTime = nil;
		self.cumulativeBlackBlockTravelTime = 0;
		self.maxScore = 0;
		self.lastScore = 0;
		self.scoreLabel?.text = "";
	}
	
	func setScoreLabel() {
		let scoreLabel = UILabel(frame: self.view.bounds)
		scoreLabel.font = scoreLabel.font.fontWithSize(64);
		scoreLabel.textAlignment = .Center;
		scoreLabel.numberOfLines = 2;
		scoreLabel.autoresizingMask = .FlexibleBottomMargin | .FlexibleTopMargin | .FlexibleLeftMargin | .FlexibleRightMargin
		self.view.insertSubview(scoreLabel, atIndex: 0)
		
		self.scoreLabel = scoreLabel
	}
	
	func updateScoreBoundary() {
		
	}
	- (void)updateScoreBoundary
	{
	CGSize scoreSize = [self.scoreLabel.text sizeWithAttributes:@{ NSFontAttributeName : self.scoreLabel.font}];
	self.scoreBoundaryCenter = self.scoreLabel.center;
	CGRect scoreRect = CGRectMake(self.scoreBoundaryCenter.x-scoreSize.width/2,
	self.scoreBoundaryCenter.y-scoreSize.height/2,
	scoreSize.width,
	scoreSize.height);
	[self.scoreBoundary removeBoundaryWithIdentifier:@"Score"];
	[self.scoreBoundary addBoundaryWithIdentifier:@"Score"
	forPath:[UIBezierPath bezierPathWithRect:scoreRect]];
	}
	
	func setScoreBoundary() {
		
	}
	- (UICollisionBehavior *)scoreBoundary
	{
	if (!_scoreBoundary) {
	UICollisionBehavior *scoreBoundary = [[UICollisionBehavior alloc] initWithItems:@[self.redBlock, self.blackBlock]];
	[self.animator addBehavior:scoreBoundary];
	_scoreBoundary = scoreBoundary;
	}
	return _scoreBoundary;
	}
	
	func setBlackBlockTracker() {
		
	}
	- (UIDynamicBehavior *)blackBlockTracker
	{
	if (!_blackBlockTracker) {
	UIDynamicItemBehavior *blackBlockTracker = [[UIDynamicItemBehavior alloc] initWithItems:@[self.blackBlock]];
	[self.animator addBehavior:blackBlockTracker];
	__weak BouncerViewController *weakSelf = self;
	__block CGPoint lastKnownBlackBlockCenter = self.blackBlock.center;
	blackBlockTracker.action = ^{
	CGFloat dx = weakSelf.blackBlock.center.x - lastKnownBlackBlockCenter.x;
	CGFloat dy = weakSelf.blackBlock.center.y - lastKnownBlackBlockCenter.y;
	weakSelf.blackBlockDistanceTraveled += sqrt(dx*dx+dy*dy);
	lastKnownBlackBlockCenter = weakSelf.blackBlock.center;
	};
	_blackBlockTracker = blackBlockTracker;
	}
	return _blackBlockTracker;
	}

	// MARK: - UIAlertView Delegate Methods
	
	func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
		if buttonIndex != alertView.cancelButtonIndex {
			self.restartGame()
		}
	}
*/
}

