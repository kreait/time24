//
//  Globals.h
//  time24
//
//  Created by kreait on 11.07.18.
//  Copyright © 2018 kreait. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject

@property (nonatomic) NSURL *movieURL;

+ (instancetype)shared;

@end
