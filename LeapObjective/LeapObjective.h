//
//  LeapObjective.h
//  Leap on Mac App
//
//  Created by Paul Solt on 11/8/12.
//  Copyright (c) 2012 Paul Solt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeapDelegate.h"

// Leap Listener
@interface LeapListener : NSObject {
}
@property (nonatomic, weak) id<LeapDelegate> delegate;
- (id)initWithDelegate:(id<LeapDelegate>)delegate;
@end

#if __cplusplus
extern "C" {
#endif

struct LeapVector {
    double x;
    double y;
    double z;
};
typedef struct LeapVector LeapVector;

struct LeapRay {
    LeapVector position;
    LeapVector direction;
};
typedef struct LeapRay LeapRay;

extern const LeapVector LeapVectorZero;
extern const LeapRay LeapRayZero;
LeapVector LeapVectorMake(double x, double y, double z);
LeapRay LeapRayMake(LeapVector position, LeapVector direction);

LeapVector *LeapVectorCreate(double x, double y, double z);
//LeapRay *LeapRayCreate(LeapVector position, LeapVector direction);
LeapRay *LeapRayCreate(double x, double y, double z, double directionX, double directionY, double directionZ);

NSString *NSStringFromLeapVector(LeapVector vector);
NSString *NSStringFromLeapRay(LeapRay ray);

#if __cplusplus
}   // Extern C
#endif

@interface LeapFinger : NSObject
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, readonly) LeapRay *tip;     // C struct
@property (nonatomic, readonly) LeapVector *velocity; // c struct
@property (nonatomic, assign) double width;
@property (nonatomic, assign) double length;
@property (nonatomic, assign) BOOL isTool;
@end

@interface LeapBall : NSObject
@property (nonatomic, readonly) LeapVector position;
@property (nonatomic, assign) double radius;
@end

@interface LeapHand : NSObject
@property (nonatomic, readonly) NSInteger id;
@property (nonatomic, strong) NSArray *fingers;
@property (nonatomic, readonly) LeapRay *palm;
@property (nonatomic, readonly) LeapVector *velocity;
@property (nonatomic, readonly) LeapVector *normal;
@property (nonatomic, readonly) LeapBall *ball;
@end

@interface LeapFrame : NSObject
@property (nonatomic, readonly) NSInteger id;
@property (nonatomic, readonly) NSInteger timestamp;
@property (nonatomic, strong) NSArray *hands;
@end

@interface LeapController : NSObject  {
}
- (LeapFrame *)frame;
- (LeapFrame *)frame:(int)frameHistory;   // 0 = current, 1 = previous, etc
@end

