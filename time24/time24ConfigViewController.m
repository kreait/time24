//
//  time24ConfigViewController.m
//  time24
//
//  Created by kreait on 11.07.18.
//  Copyright © 2018 kreait. All rights reserved.
//

#import "time24ConfigViewController.h"
#import "Globals.h"

@interface time24ConfigViewController ()
@property (weak) IBOutlet NSTextField *pathField;

@end

@implementation time24ConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (IBAction)confirmConfig:(NSButton *)sender {
    [self dismissController:nil];
}

@end
