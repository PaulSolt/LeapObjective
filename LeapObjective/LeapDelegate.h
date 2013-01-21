//
//  LeapDelegate.h
//  Leap on Mac App
//
//  Created by Paul Solt on 11/9/12.
//  Copyright (c) 2012 Paul Solt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LeapController;
@class LeapListener;

@protocol LeapDelegate <NSObject>
- (void)onInit:(LeapController *)controller;
- (void)onConnect:(LeapController *)controller;
- (void)onDisconnect:(LeapController *)controller;
- (void)onFrame:(LeapController *)controller;
@end
