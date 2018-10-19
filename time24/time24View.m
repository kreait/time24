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
#import "AVTime24Player.h"
#import "Globals.h"


@interface time24View () <NSTableViewDataSource>
@property AVPlayerView *playerView;
@property AVTime24Player *player;
@property NSArray<NSString*> *fileList;
@property (weak) IBOutlet NSWindow *config;
@property (weak) IBOutlet NSTableView *tableView;
@property NSString *moviesFolder;
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
    NSLog(@"time24 view added %f x %f", self.playerView.frame.size.width, self.playerView.frame.size.height);
    [self addSubview:self.playerView];
  }
  
  return self;
}

- (void)startAnimation {
  [super startAnimation];
  
  NSURL *url = Globals.shared.movieURL;
//  NSLog(@"time24 preload %@", url.absoluteString);
  self.player = [AVTime24Player playerWithURL:url preloadCompletion:^(AVPlayerItemStatus status) {
//    NSLog(@"time24 preloaded");
    if (status == AVPlayerItemStatusReadyToPlay) {
      self.playerView.player = self.player;
//      NSLog(@"time24 seek");
      [self.player seekToCurrentTime24OnCompletion:^(BOOL finished) {
//        NSLog(@"time24 seeked");
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateAnimation) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [self.player play];
      }];
    }
  }];
}

- (void)stopAnimation {
  [super stopAnimation];
  
  [NSNotificationCenter.defaultCenter removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
  [self.player pause];
}

- (void)updateAnimation {
  [self.player seekToCurrentTime24OnCompletion:^(BOOL finished) {
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
  NSFileManager *fm = NSFileManager.defaultManager;
  NSError *error;
  NSURL *movies = [fm URLsForDirectory:NSMoviesDirectory inDomains:NSUserDomainMask].firstObject;
  self.moviesFolder = [movies.absoluteString substringFromIndex:7];
  self.fileList = [fm contentsOfDirectoryAtPath: self.moviesFolder error:&error];
  self.fileList = [self.fileList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *object, NSDictionary<NSString *,id> * _Nullable bindings) {
    return object.pathExtension.length > 0 && [@[@"mp4", @"m4v", @"mov"] containsObject:object.pathExtension];
  }]];
  self.fileList = [self.fileList sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
    return [obj1 compare:obj2];
  }];
  [self.tableView reloadData];
}

- (IBAction)confirm:(NSButton *)sender {
  if (NSApp.currentEvent.modifierFlags & NSEventModifierFlagCommand) {
    Globals.shared.movieURL = Globals.shared.defaultURL;
  }
  [[NSApplication sharedApplication] endSheet:self.config];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return self.fileList.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
  return self.fileList[row];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
  NSString *filename = [NSString stringWithFormat: @"%@%@", self.moviesFolder, self.fileList[row]];
  Globals.shared.movieURL = [NSURL fileURLWithPath: filename];
  return YES;
}

@end
