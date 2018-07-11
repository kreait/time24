//
//  time24View.m
//  time24
//
//  Created by kreait on 10.07.18.
//  Copyright © 2018 kreait. All rights reserved.
//

#import "time24View.h"
#import <AVKit/AVKit.h>
#import <os/log.h>
#import "Globals.h"

@interface time24View ()
@property (nonatomic) AVPlayerView *playerView;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) NSTimer *playerTimer;
@property (nonatomic) os_log_t log;
@property (nonatomic, weak) IBOutlet NSWindow *config;
@property (nonatomic, weak) IBOutlet NSTextField *pathField;
@end

@implementation time24View

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    
    [self setAnimationTimeInterval:1/30.0];

    self.log = os_log_create("com.kreait.time24" , "timer");
    
    if (self) {
        /*
        NSURL *url = [Globals shared].path;
        self.player = [AVPlayer playerWithURL:url];
        */
        NSRect mainRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.playerView = [[AVPlayerView alloc] initWithFrame:mainRect];
        //        self.playerView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        //        self.playerView.autoresizesSubviews = YES;
        self.playerView.videoGravity = AVLayerVideoGravityResize;
        self.playerView.controlsStyle = AVPlayerViewControlsStyleNone;
        [self addSubview:self.playerView];
        /*
        self.playerView.player = self.player;
         */
    }
    
    return self;
}
/*
- (void) printRect: (NSRect) rect named:(NSString*) name {
    os_log_error(self.log, "%@ %f,%f %fx%f", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}
*/
- (CMTime) currentTime {
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
    NSTimeInterval time = [now timeIntervalSinceDate:zero];
    return CMTimeMakeWithSeconds(time, 1);
}

- (void)startAnimation {
    [super startAnimation];

    NSURL *url = [Globals shared].movieURL;
    os_log_error(self.log, "start animation");
    os_log_error(self.log, "movie url %@", [url.absoluteString stringByReplacingOccurrencesOfString:@"/" withString:@"-"]);
    self.player = [AVPlayer playerWithURL:url];
    self.playerView.player = self.player;

    [self.player seekToTime:self.currentTime completionHandler:^(BOOL finished) {
        [self.player play];
    }];
    
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:60 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self.player seekToTime:self.currentTime];
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
    return NO;// YES;
}

- (NSWindow*)configureSheet {
    return nil;
    if (!self.config) {
        NSArray *list;
        [[NSBundle bundleForClass:self.class] loadNibNamed:@"Config" owner:self topLevelObjects:&list];
        
        self.config = list.lastObject;
    }
    return self.config;
    /*

    [[[NSNib alloc] initWithNibNamed:@"Config" bundle:[NSBundle bundleForClass:self.class]] instantiateWithOwner:self topLevelObjects:&list];
    return list.lastObject;
    NSWindowController *ctrl = [[NSStoryboard storyboardWithName:@"time24Config" bundle:[NSBundle bundleForClass:self.class]] instantiateInitialController];
    [ctrl loadWindow];
    return ctrl.window;
    */
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.pathField.stringValue = [Globals shared].movieURL.absoluteString;
}

- (IBAction)selectPath:(NSButton *)sender {
    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    panel.canChooseDirectories = NO;
    panel.canChooseFiles = YES;
    if ([panel runModal] == NSModalResponseOK) {
        [Globals shared].movieURL = panel.URLs.firstObject;
        self.pathField.stringValue = [Globals shared].movieURL.absoluteString;
    }
}

- (IBAction)confirm:(NSButton *)sender {
    [[NSApplication sharedApplication] endSheet:self.config];
}

@end
