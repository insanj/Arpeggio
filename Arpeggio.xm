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
- (BOOL)isSeekingOrScrubbing;
- (void)beginSeek:(NSInteger)direction;
- (void)endSeek;
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
- (void)arpeggio_oneFingerPressRecognized:(UILongPressGestureRecognizer *)sender;
- (void)arpeggio_twoFingerPressRecognized:(UILongPressGestureRecognizer *)sender;
@end

static UILongPressGestureRecognizer *arpeggioLongPressOneFingerGestureRecognizer, *arpeggioLongPressTwoFingersGestureRecognizer;
static UISwipeGestureRecognizer *arpeggioLeftSwipeGestureRecognizer, *arpeggioRightSwipeGestureRecognizer;

%hook MusicNowPlayingViewController

- (void)viewDidLayoutSubviews {
	%orig();

	if (![self.view.gestureRecognizers containsObject:arpeggioRightSwipeGestureRecognizer]) {	
		arpeggioLeftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_leftSwipeRecognized:)];
		arpeggioRightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_rightSwipeRecognized:)];
		
		arpeggioLeftSwipeGestureRecognizer.delaysTouchesBegan =
		arpeggioRightSwipeGestureRecognizer.delaysTouchesBegan = YES;

		arpeggioLeftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		arpeggioRightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;

		arpeggioLongPressOneFingerGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_oneFingerPressRecognized:)];
		arpeggioLongPressTwoFingersGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_twoFingerPressRecognized:)];

		arpeggioLongPressOneFingerGestureRecognizer.numberOfTouchesRequired = 1;
		arpeggioLongPressTwoFingersGestureRecognizer.numberOfTouchesRequired = 2;

		[self.view addGestureRecognizer:arpeggioLeftSwipeGestureRecognizer];
		[self.view addGestureRecognizer:arpeggioRightSwipeGestureRecognizer];
		[self.view addGestureRecognizer:arpeggioLongPressOneFingerGestureRecognizer];
		[self.view addGestureRecognizer:arpeggioLongPressTwoFingersGestureRecognizer];

		NSLog(@"[Arpeggio] Added gesture recognizers in %@ (%@) for swipe recognition", self, self.view);
	}
}

%new
- (void)arpeggio_leftSwipeRecognized:(UISwipeGestureRecognizer *)sender { // previous track
	NSLog(@"[Arpeggio] Recognized swipe from %@...", sender);

	// MPUTransportControl *previousTrackControl = [self.transportControls availableTransportControlWithType:1];
	[self transportControlsView:self.transportControls tapOnControlType:1];
	NSLog(@"[Arpeggio] Seeked to the previous track using %@", self.transportControls);
}

%new
- (void)arpeggio_rightSwipeRecognized:(UISwipeGestureRecognizer *)sender { // next track
	[self transportControlsView:self.transportControls tapOnControlType:4];
	NSLog(@"[Arpeggio] Seeked to the next track using %@", self.transportControls);
}

%new
- (void)arpeggio_oneFingerPressRecognized:(UILongPressGestureRecognizer *)sender { // seek forward, or stop seeking
	if (sender.state == UIGestureRecognizerStateEnded) {
		[self.player endSeek];
		NSLog(@"[Arpeggio] Ended seeking or scrubbing with %@", self.player);
	}

	else {
		[self.player beginSeek:2];
		NSLog(@"[Arpeggio] Began seeking forward with %@", self.player);
	}
}

%new
- (void)arpeggio_twoFingerPressRecognized:(UILongPressGestureRecognizer *)sender { // seek backward, or stop seeking
	if (sender.state == UIGestureRecognizerStateEnded) {
		[self.player endSeek];
		NSLog(@"[Arpeggio] Ended seeking or scrubbing with %@", self.player);
	}

	else {
		[self.player beginSeek:-2];
		NSLog(@"[Arpeggio] Began seeking backward with %@", self.player);
	}	
}

/*%new - (BOOL)gestureRecognizer:(UIGestureRecognizer * nonnull)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer * nonnull)otherGestureRecognizer {
	return NO;
}*/

%end
