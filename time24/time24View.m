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
@property (nonatomic) NSTimer *playerTimer;
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

- (CMTime) seekTimeForDuration: (CMTime) duration {
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

    // roll it
    if (duration.value > 0 && duration.timescale > 0) {
        NSTimeInterval trackSeconds = (double)duration.value / (double) duration.timescale;
        NSTimeInterval offset = floor(daySeconds / trackSeconds);
        daySeconds = daySeconds - offset * trackSeconds;
    }

    return CMTimeMakeWithSeconds(daySeconds, 1);
}

- (void)startAnimation {
    [super startAnimation];

    NSURL *url = [Globals shared].movieURL;
    self.player = [AVPlayer playerWithURL:url];
    self.playerView.player = self.player;

    void (^updater)(void) = ^() {
        [self.player seekToTime:[self seekTimeForDuration:self.player.currentItem.duration] completionHandler:^(BOOL finished) {
            [self.player play];
        }];
    };

    // rectify every 60 seconds
    updater();
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:60 repeats:YES block:^(NSTimer *timer) {
        updater();
    }];
}

- (void)stopAnimation {
    [super stopAnimation];

    if (self.playerTimer) {
        [self.playerTimer invalidate];
        self.playerTimer = nil;
    }
    [self.player pause];
}

- (BOOL)hasConfigureSheet {
    return YES;
}

- (NSWindow*)configureSheet {
    if (!self.config) {
        [[NSBundle bundleForClass:self.class] loadNibNamed:@"Config" owner:self topLevelObjects:nil];
    }
    return self.config;
}

#pragma mark - view handling

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.pathField.stringValue = [[Globals shared].movieURL.absoluteString substringFromIndex:7];
}

- (IBAction)selectPath:(NSButton *)sender {
    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    panel.canChooseDirectories = NO;
    panel.canChooseFiles = YES;
    panel.allowedFileTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeVideo];
    if ([panel runModal] == NSModalResponseOK) {
        NSURL *url = panel.URLs.firstObject;
        [Globals shared].movieURL = url;
        self.pathField.stringValue = [url.absoluteString substringFromIndex:7];
    }
}

- (IBAction)confirm:(NSButton *)sender {
    [[NSApplication sharedApplication] endSheet:self.config];
}

@end
