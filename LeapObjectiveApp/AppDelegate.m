//
//  AppDelegate.m
//  LeapObjectiveApp
//
//  Created by Paul Solt on 11/20/12.
//  Copyright (c) 2012 Paul Solt. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Just create a ivar for the listener and set yourself as the delegate
    listener = [[LeapListener alloc] initWithDelegate:self];
}

#pragma mark - LeapDelegate Methods
- (void)onInit:(LeapController *)controller {
    NSLog(@"onInit");
}
- (void)onConnect:(LeapController *)controller {
    NSLog(@"onConnect");
}
- (void)onDisconnect:(LeapController *)controller {
    NSLog(@"onDisconnect");
}
- (void)onFrame:(LeapController *)controller {
    NSLog(@"onFrame");
    
    // Use the Objective-C objects to work with Leap data
    
    LeapFrame *frame = controller.frame;
    NSArray *hands = frame.hands;
    
    for(LeapHand *hand in hands) {
        NSLog(@"\n%@", hand);
        NSString *fingerString = @"";
        for(LeapFinger *finger in hand.fingers) {
            fingerString = [fingerString stringByAppendingFormat:@"\t%@\n", finger];
        }
        NSLog(@"Fingers: \n%@", fingerString);
        
    }
}
@end
