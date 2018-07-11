//
//  Globals.m
//  time24
//
//  Created by kreait on 11.07.18.
//  Copyright © 2018 kreait. All rights reserved.
//

#import "Globals.h"
#import <ScreenSaver/ScreenSaver.h>
#import "time24View.h"

@interface Globals ()
@property (nonatomic) ScreenSaverDefaults *defaults;
@property (nonatomic, readonly) NSURL *defaultURL;
@end

@implementation Globals

+ (Globals*)shared {
    static Globals *_globals;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globals = [[Globals alloc] init];
    });
    return _globals;
}

- (instancetype) init {
    if ((self = [super init])) {
        self.defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"com.kreait.time24"];
        [self.defaults registerDefaults:@{@"URL": self.defaultURL}];
    }
    return self;
}

- (NSURL*) defaultURL {
    return [[NSBundle bundleForClass:time24View.class] URLForResource:@"kreait" withExtension:@"mp4"];
}

- (void)setMovieURL:(NSURL *)url {
    [self.defaults setURL:url forKey:@"URL"];
    [self.defaults synchronize];
}

- (NSURL*)movieURL {
    NSURL *url = [self.defaults URLForKey:@"URL"];
    if (!url) {
        url = self.defaultURL;
    }
    return url;
}

@end
