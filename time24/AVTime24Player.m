//
//  AVPlayerItem+Prepare.m
//  time24
//
//  Created by Oliver Michalak on 25.07.18.
//  Copyright © 2018 Oliver Michalak. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <objc/runtime.h>
#import "AVTime24Player.h"

static void * const PlayerItemContext = (void*)&PlayerItemContext;

@interface AVTime24Player ()
@property (nonatomic, copy) void (^completion)(AVPlayerItemStatus status);
@property (nonatomic, readonly) CMTime currentTime24;
@end

@implementation AVTime24Player

+ (instancetype) playerWithURL:(NSURL *)url preloadCompletion:(void (^)(AVPlayerItemStatus status))completion {
	AVAsset *asset = [AVAsset assetWithURL:url];
	NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset automaticallyLoadedAssetKeys:assetKeys];
	NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
	AVTime24Player *player = [AVTime24Player playerWithPlayerItem:playerItem];
	[playerItem addObserver:player forKeyPath:@"status" options:options context:PlayerItemContext];
	player.completion = completion;
	return player;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {

	if (context != PlayerItemContext) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		return;
	}
	
	if ([keyPath isEqualToString:@"status"]) {

		[self.currentItem removeObserver:self forKeyPath:@"status" context:PlayerItemContext];
		
		AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
		NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
		if ([statusNumber isKindOfClass:NSNumber.class]) {
			status = statusNumber.integerValue;
		}

//		NSLog(@"⏰ got value %ld", status);
		self.completion(status);
		self.completion = nil;
	}
}

- (CMTime)currentTime24 {
	CMTime duration = self.currentItem.duration;
	NSDate *now = [NSDate date];
	NSDateComponents *nowComp = [NSCalendar.currentCalendar componentsInTimeZone:NSTimeZone.defaultTimeZone fromDate:now];
	NSDateComponents *zeroComp = [[NSDateComponents alloc] init];
	zeroComp.day = nowComp.day;
	zeroComp.month = nowComp.month;
	zeroComp.year = nowComp.year;
	zeroComp.nanosecond = nowComp.nanosecond;
	zeroComp.hour = 0;
	zeroComp.minute = 0;
	zeroComp.second = 0;
	NSDate *zero = [NSCalendar.currentCalendar dateFromComponents:zeroComp];
	NSTimeInterval daySeconds = [now timeIntervalSinceDate:zero];
	
	// adjust/roll it if available
	if (duration.value > 0 && duration.timescale > 0) {
		NSTimeInterval trackSeconds = (double)duration.value / (double) duration.timescale;
		NSTimeInterval offset = floor(daySeconds / trackSeconds);
		daySeconds = daySeconds - offset * trackSeconds;
	}
	
  NSLog(@"time24 %f vs %f", daySeconds, (double)self.currentItem.currentTime.value/(double)self.currentItem.currentTime.timescale);
	return CMTimeMakeWithSeconds(daySeconds, 1);
}

- (void) seekToCurrentTime24OnCompletion:(void(^)(BOOL finished))completion {
	[self seekToTime:self.currentTime24 toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
		completion(finished);
	}];
}

@end
