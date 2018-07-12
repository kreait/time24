//
//  time24View.m
//  time24
//
//  Created by kreait on 10.07.18.
//  Copyright © 2018 kreait. All rights reserved.
//

#import "time24View.h"
#import <AVKit/AVKit.h>
#import <CoreServices/CoreServices.h>
#import "Globals.h"


@interface time24View ()
@property (nonatomic) AVPlayerView *playerView;
@property (nonatomic) AVPlayer *player;
@property (nonatomic, weak) IBOutlet NSWindow *config;
@property (nonatomic, weak) IBOutlet NSTextField *pathField;
@end

@implementation time24View

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    
    [self setAnimationTimeInterval:1/30.0]; // all templates include this, is this even needed for a movie?

    if (self) {
        NSRect mainRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.playerView = [[AVPlayerView alloc] initWithFrame:mainRect];
        //        self.playerView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        //        self.playerView.autoresizesSubviews = YES;
        self.playerView.videoGravity = AVLayerVideoGravityResize;
        self.playerView.controlsStyle = AVPlayerViewControlsStyleNone;
        [self addSubview:self.playerView];
    }
    
    return self;
}

- (CMTime)seekTimeForDuration: (CMTime)duration {
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

//    NSLog(@"⏰ %f vs %f", daySeconds, (double)self.player.currentItem.currentTime.value/(double)self.player.currentItem.currentTime.timescale);
    return CMTimeMakeWithSeconds(daySeconds, 1);
}

- (void)startAnimation {
    [super startAnimation];

    NSURL *url = Globals.shared.movieURL;
    self.player = [AVPlayer playerWithURL:url];
    self.playerView.player = self.player;

    [self.player seekToTime:[self seekTimeForDuration:self.player.currentItem.duration] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateAnimation) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [self.player play];
    }];
}

- (void)stopAnimation {
    [super stopAnimation];

    [NSNotificationCenter.defaultCenter removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.player pause];
}

- (void)updateAnimation {
    [self.player seekToTime:[self seekTimeForDuration:self.player.currentItem.duration] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self.player play];
    }];
}

#pragma mark - view handling

- (BOOL)hasConfigureSheet {
    return YES;
}

- (NSWindow*)configureSheet {
    if (!self.config) {
        [[NSBundle bundleForClass:self.class] loadNibNamed:@"Config" owner:self topLevelObjects:nil];
    }
    return self.config;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.pathField.stringValue = Globals.shared.movieName;
}

- (IBAction)selectPath:(NSButton *)sender {

    // reset to default movie if CMD pressed
    if (NSApp.currentEvent.modifierFlags & NSEventModifierFlagCommand) {
        Globals.shared.movieURL = Globals.shared.defaultURL;
    }
    else {
        NSOpenPanel *panel = [[NSOpenPanel alloc] init];
        panel.canChooseDirectories = NO;
        panel.canChooseFiles = YES;
        panel.allowedFileTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeVideo];
        if ([panel runModal] == NSModalResponseOK) {
            NSURL *url = panel.URLs.firstObject;
            Globals.shared.movieURL = url;
        }
    }
    self.pathField.stringValue = Globals.shared.movieName;
}

- (IBAction)confirm:(NSButton *)sender {
    [[NSApplication sharedApplication] endSheet:self.config];
}

@end
