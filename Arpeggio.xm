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
- (MPUTransportControl)availableTransportControlWithType:(NSInteger)type;
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

- (void)viewDidAppear:(BOOL)animated {
	%orig(animated);

	UIView *albumArtworkView = self.currentItemViewController.view.subviews[0];

	if (arpeggioSwipeGestureRecognizer) {
		[albumArtworkView removeGestureRecognizer:arpeggioSwipeGestureRecognizer];
		arpeggioSwipeGestureRecognizer = nil;
	}
	
	arpeggioSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(arpeggio_swipeRecognized:)];
	// arpeggioSwipeGestureRecognizer.delegate = self;
	swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
	[albumArtworkView addGestureRecognizer:swipeRecognizer];
}

- (void)arpeggio_swipeRecognized:(UISwipeGestureRecognizer *)sender {
	if (sender.state != UIGestureRecognizerStateEnded) {
		return;
	}

	switch(swipeGestureRecognizer.direction) {
		case UISwipeGestureRecognizerDirectionRight: // previous track
			// MPUTransportControl *previousTrackControl = [self.transportControls availableTransportControlWithType:1];
			[self transportControlsView:self.transportControls tapOnControlType:1];
			break;
		case UISwipeGestureRecognizerDirectionLeft: // next track
			[self transportControlsView:self.transportControls tapOnControlType:4];
			break;
		case UISwipeGestureRecognizerDirectionUp: { // seek forward, or stop seeking
			if ([self.player isSeekingOrScrubbing]) {
				[self.player endSeek];
			}

			else {
				[self.player beginSeek:1];
			}
			break;
		}	
		case UISwipeGestureRecognizerDirectionDown: { // seek backwards, or stop seeking
			if ([self.player isSeekingOrScrubbing]) {
				[self.player endSeek];
			}

			else {
				[self.player beginSeek:-1];
			}			
			break;
		}
	}
}

/*%new - (BOOL)gestureRecognizer:(UIGestureRecognizer * nonnull)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer * nonnull)otherGestureRecognizer {
	return NO;
}*/

%end