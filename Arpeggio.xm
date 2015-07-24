//
//  Arpeggio.xm
//  Arpeggio
//	
//  Created by Julian Weiss on 7/23/15.
//  Copyright (c) 2015, insanj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusicNowPlayingItemViewController;

@interface MPUTransportControl : UIView
@end

@interface MPUTransportControlsView : UIView
- (MPUTransportControl *)availableTransportControlWithType:(NSInteger)type;
@end

@interface MusicAVPlayer : NSObject
@property (nonatomic, readwrite) NSTimeInterval currentTime;
- (BOOL)isSeekingOrScrubbing;
- (void)beginSeek:(NSInteger)direction;
- (void)endSeek;
- (void)togglePlayback;
- (void)changePlaybackIndexBy:(CGFloat)index;
@end

@interface MusicNowPlayingViewController : UIViewController
- (MusicAVPlayer *)player;
- (MusicNowPlayingItemViewController *)currentItemViewController;
- (MPUTransportControlsView *)transportControls;
- (void)transportControlsView:(MPUTransportControlsView *)view tapOnControlType:(NSInteger)type;
@end

@interface MusicNowPlayingItemViewController : MusicNowPlayingViewController
@end

@interface MusicNowPlayingViewController (Arpeggio) <UIGestureRecognizerDelegate>
- (void)arpeggio_leftSwipeRecognized:(UISwipeGestureRecognizer *)sender;
- (void)arpeggio_rightSwipeRecognized:(UISwipeGestureRecognizer *)sender;
- (void)arpeggio_leftDoubleSwipeRecognized:(UILongPressGestureRecognizer *)sender;
- (void)arpeggio_rightDoubleSwipeRecognized:(UILongPressGestureRecognizer *)sender;
- (void)arpeggio_pressRecognized:(UILongPressGestureRecognizer *)sender;
@end

static UISwipeGestureRecognizer *arpeggioLeftSwipeGestureRecognizer, *arpeggioRightSwipeGestureRecognizer, *arpeggioLeftDoubleSwipeGestureRecognizer, *arpeggioRightDoubleSwipeGestureRecognizer;
static UILongPressGestureRecognizer *arpeggioPressGestureRecognizer;

%hook MusicNowPlayingViewController

- (void)viewDidLayoutSubviews {
	%orig();

	if (![self.view.gestureRecognizers containsObject:arpeggioRightSwipeGestureRecognizer]) {	
		arpeggioLeftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_leftSwipeRecognized:)];
		arpeggioRightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_rightSwipeRecognized:)];
		arpeggioLeftDoubleSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_leftDoubleSwipeRecognized:)];
		arpeggioRightDoubleSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_rightDoubleSwipeRecognized:)];
		arpeggioPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_pressRecognized:)];

		arpeggioLeftDoubleSwipeGestureRecognizer.direction =
		arpeggioLeftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;

		arpeggioRightDoubleSwipeGestureRecognizer.direction =
		arpeggioRightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;

		arpeggioLeftDoubleSwipeGestureRecognizer.numberOfTouchesRequired = 
		arpeggioRightDoubleSwipeGestureRecognizer.numberOfTouchesRequired = 2;

		[self.view addGestureRecognizer:arpeggioLeftDoubleSwipeGestureRecognizer];
		[self.view addGestureRecognizer:arpeggioLeftSwipeGestureRecognizer];
		[self.view addGestureRecognizer:arpeggioRightDoubleSwipeGestureRecognizer];
		[self.view addGestureRecognizer:arpeggioRightSwipeGestureRecognizer];
		[self.view addGestureRecognizer:arpeggioPressGestureRecognizer];

		NSLog(@"[Arpeggio] Added gesture recognizers in %@ (%@) for swipe recognition", self, self.view);
	}
}

%new
- (void)arpeggio_leftSwipeRecognized:(UISwipeGestureRecognizer *)sender { // next track
	if (sender.state == UIGestureRecognizerStateEnded) {
		[self transportControlsView:self.transportControls tapOnControlType:4];
	}
}

%new
- (void)arpeggio_rightSwipeRecognized:(UISwipeGestureRecognizer *)sender { // previous track
	if (sender.state == UIGestureRecognizerStateEnded) {
		[self transportControlsView:self.transportControls tapOnControlType:1];
	}
}

%new
- (void)arpeggio_leftDoubleSwipeRecognized:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateEnded) {
		self.player.currentTime = self.player.currentTime + 15;
	}
}

%new
- (void)arpeggio_rightDoubleSwipeRecognized:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateEnded) {
		self.player.currentTime = self.player.currentTime - 15;
	}
}

%new
- (void)arpeggio_pressRecognized:(UILongPressGestureRecognizer *)sender {
	if (sender.state != UIGestureRecognizerStateEnded) {
		[self.player togglePlayback];
	}
}

%end
