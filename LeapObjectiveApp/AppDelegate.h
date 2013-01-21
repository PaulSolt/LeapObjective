//
//  AppDelegate.h
//  LeapObjectiveApp
//
//  Created by Paul Solt on 11/20/12.
//  Copyright (c) 2012 Paul Solt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LeapObjective.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, LeapDelegate> {
    LeapListener *listener;
}

@property (assign) IBOutlet NSWindow *window;

@end
