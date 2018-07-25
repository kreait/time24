//
//  AVPlayerItem+Prepare.h
//  time24
//
//  Created by Oliver Michalak on 25.07.18.
//  Copyright © 2018 Oliver Michalak. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface AVTime24Player: AVPlayer

+ (instancetype) playerWithURL:(NSURL *)URL preloadCompletion:(void (^)(AVPlayerItemStatus status))completion;
- (void) seekToCurrentTime24OnCompletion:(void(^)(BOOL finished))completion;

@end

