//
//  Arpeggio.xm
//  Arpeggio
//	
//  Created by Julian Weiss on 7/23/15.
//  Copyright (c) 2015, insanj. All rights reserved.
//

#import <UIKit/UIKit.h>

static UISwipeGestureRecognizer *arpeggioSwipeGestureRecognizer;

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
- (void)arpeggio_swipeRecognized:(UISwipeGestureRecognizer *)sender;
@end


%hook MusicNowPlayingViewController

- (void)viewDidLayoutSubviews {
	%orig();

	if (![self.view.gestureRecognizers containsObject:arpeggioSwipeGestureRecognizer]) {	
		arpeggioSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_swipeRecognized:)];
		arpeggioSwipeGestureRecognizer.cancelsTouchesInView = YES;
		arpeggioSwipeGestureRecognizer.delaysTouchesBegan = YES;
		// arpeggioSwipeGestureRecognizer.delegate = self;
		arpeggioSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
		[self.view addGestureRecognizer:arpeggioSwipeGestureRecognizer];

		NSLog(@"[Arpeggio] Added %@ to %@ in %@ for swipe recognition!", arpeggioSwipeGestureRecognizer, self.view, self);
	}
}

%new
- (void)arpeggio_swipeRecognized:(UISwipeGestureRecognizer *)sender {
	NSLog(@"[Arpeggio] Recognized swipe from %@...", sender);
	if (sender.direction | UISwipeGestureRecognizerDirectionLeft) { // previous track
		// MPUTransportControl *previousTrackControl = [self.transportControls availableTransportControlWithType:1];
		[self transportControlsView:self.transportControls tapOnControlType:1];
		NSLog(@"[Arpeggio] Seeked to the previous track using %@", self.transportControls);
	}

	else if (sender.direction | UISwipeGestureRecognizerDirectionRight) { // next track
		[self transportControlsView:self.transportControls tapOnControlType:4];
		NSLog(@"[Arpeggio] Seeked to the next track using %@", self.transportControls);
	}

	else if (sender.direction | UISwipeGestureRecognizerDirectionUp) {  // seek forward, or stop seeking
		if ([self.player isSeekingOrScrubbing]) {
			[self.player endSeek];
			NSLog(@"[Arpeggio] Ended seeking or scrubbing with %@", self.player);
		}

		else {
			[self.player beginSeek:1];
			NSLog(@"[Arpeggio] Began seeking forward with %@", self.player);
		}
	}
	
	else if (sender.direction | UISwipeGestureRecognizerDirectionDown) { // seek backwards, or stop seeking
		if ([self.player isSeekingOrScrubbing]) {
			[self.player endSeek];
			NSLog(@"[Arpeggio] Ended seeking or scrubbing with %@", self.player);
		}

		else {
			[self.player beginSeek:-1];
			NSLog(@"[Arpeggio] Began seeking backward with %@", self.player);
		}			
	}

	else {
		NSLog(@"[Arpeggio] Swiped in impossible direction: %i. The possibilities are normally left (%i), right (%i), up (%i), or down (%i).", (int)sender.direction, (int)UISwipeGestureRecognizerDirectionLeft, (int)UISwipeGestureRecognizerDirectionRight, (int)UISwipeGestureRecognizerDirectionUp, (int)UISwipeGestureRecognizerDirectionDown);
	}
}

/*%new - (BOOL)gestureRecognizer:(UIGestureRecognizer * nonnull)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer * nonnull)otherGestureRecognizer {
	return NO;
}*/

%end
