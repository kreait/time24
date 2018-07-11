//
//  Config.m
//  time24
//
//  Created by kreait on 11.07.18.
//  Copyright © 2018 kreait. All rights reserved.
//

#import "Config.h"
#import <Cocoa/Cocoa.h>
#import "Globals.h"


@interface Config ()
@property (weak) IBOutlet NSTextField *pathField;

@end

@implementation Config

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
}

@end
