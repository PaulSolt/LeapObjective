//
//  LeapObjective.m
//  Leap on Mac App
//
//  Created by Paul Solt on 11/8/12.
//  Copyright (c) 2012 Paul Solt. All rights reserved.
//

#import "LeapObjective.h"
#import "Leap.h"

struct ListenerOpaque;
struct ControllerOpaque;

@interface LeapListener() {
    LeapController *_controller;
    ListenerOpaque *_listener;
}
- (void)onInit;
- (void)onConnect;
- (void)onDisconnect;
- (void)onFrame;
@end

class ListenerSubclass : public Leap::Listener {
public:
    ListenerSubclass(LeapListener *owner) : leapListener(owner) {

    }
    virtual void onInit(const Leap::Controller&) {
        [leapListener onInit];
    }
    virtual void onConnect(const Leap::Controller&) {
        [leapListener onConnect];
    }
    virtual void onDisconnect(const Leap::Controller&) {
        [leapListener onDisconnect];
    }
    virtual void onFrame(const Leap::Controller&) {
        [leapListener onFrame];
    }
    
private:
    LeapListener *leapListener;
};

#pragma mark LeapVector and LeapRay helper methods
LeapVector LeapVectorMake(double x, double y, double z) {
    LeapVector vector;
    vector.x = x;
    vector.y = y;
    vector.z = z;
    return vector;
}

LeapRay LeapRayMake(LeapVector position, LeapVector direction) {
    LeapRay ray;
    ray.position = position;
    ray.direction = direction;
    return ray;
}

LeapVector *LeapVectorCreate(double x, double y, double z) {
    LeapVector *vector = new LeapVector;
    vector->x = x;
    vector->y = y;
    vector->z = z;
    return vector;
}

// Duplicate names issue due to C++ in Objc, no name mangling
//LeapRay *LeapRayCreate(LeapVector position, LeapVector direction) {
//    LeapRay *ray = new LeapRay;
//    ray->position = position;
//    ray->direction = direction;
//    return ray;
//}

LeapRay *LeapRayCreate(double x, double y, double z, double directionX, double directionY, double directionZ) {
    LeapRay *ray = new LeapRay;
    ray->position.x = x;
    ray->position.y = y;
    ray->position.z = z;
    
    ray->direction.x = directionX;
    ray->direction.y = directionY;
    ray->direction.z = directionZ;
    return ray;
}


const LeapVector LeapVectorZero = { .x = 0, .y = 0, .z = 0 };
const LeapRay LeapRayZero = {   .position = { .x = 0, .y = 0, .z = 0},
                                .direction = { .x = 0, .y = 0, .z = 0} };

NSString *NSStringFromLeapVector(LeapVector vector) {
    NSString *value = nil;
    value = [NSString stringWithFormat:@"(%0.2f, %0.2f, %0.2f)", vector.x, vector.y, vector.z];
    return value;
}

NSString *NSStringFromLeapRay(LeapRay ray) {
    NSString *value = nil;
    value = [NSString stringWithFormat:@"Position: %@ Direction: %@", NSStringFromLeapVector(ray.position), NSStringFromLeapVector(ray.direction)];
    return value;
}

#pragma mark - Finger

@interface LeapFinger () {
}
@end

@implementation LeapFinger
- (id)initWithFinger:(Leap::Finger)finger {
    self = [super init];
    if(self) {
        if(!_tip) {
            _velocity = NULL;
            _tip = NULL;

            // FIXME: The Leap::Finger.tip() isn't a pointer, we shouldn't create a pointer
            const Leap::Ray leapRay = finger.tip(); 
            _tip = LeapRayCreate(leapRay.position.x, leapRay.position.y, leapRay.position.z,
                                 leapRay.direction.x, leapRay.direction.y, leapRay.direction.z);
            
            const Leap::Vector *leapVector = finger.velocity();
            // Create leapVector if vector not created, only when valid leapVector
            if(leapVector) {
                _velocity = LeapVectorCreate(leapVector->x, leapVector->y, leapVector->z);
            }
            
            _id = finger.id();
            _width = finger.width();
            _length = finger.length();
            _isTool = finger.isTool();
        }

    }
    return self;
}

- (void)dealloc {
    if(_velocity) {
        delete _velocity;
        _velocity = NULL;
    }
    if(_tip) {
        delete _tip;
        _tip = NULL;
    }
}

- (NSString *)description {
    NSString *tipString = nil;
    if([self tip]) {
        tipString = NSStringFromLeapRay(*[self tip]);
    }
    NSString *velocityString = nil;
    if([self velocity]) {
        velocityString = NSStringFromLeapVector(*[self velocity]);
    }
    return [NSString stringWithFormat:@"Finger id: %ld Tip: %@ Velocity: %@", [self id], tipString, velocityString];
}
@end

#pragma mark - Ball

@implementation LeapBall

- (id)initWithBall:(Leap::Ball)ball {
    self = [super init];
    if(self) {
        _position = LeapVectorMake(ball.position.x, ball.position.y, ball.position.z);
        _radius = ball.radius;
    }
    return self;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"Position: %@ Radius: %f", NSStringFromLeapVector(_position), _radius];
}
@end

#pragma mark - Hand

@interface LeapHand() {
}
@end

@implementation LeapHand
- (id)init {
    throw [NSException exceptionWithName:@"Invalid init" reason:@"Do not attempt to create hand with init" userInfo:nil];
    return nil;
}

- (id)initWithHand:(Leap::Hand)hand {
    self = [super init];
    if(self) {
        _id = hand.id();
        _fingers = nil;
        _palm = NULL;
        _velocity = NULL;
        _normal = NULL;
        _ball = nil;
        
        const Leap::Ray *palmRay = hand.palm();
        if(palmRay) {
            _palm = LeapRayCreate(palmRay->position.x, palmRay->position.y, palmRay->position.z,
                                  palmRay->direction.x, palmRay->direction.y, palmRay->direction.z);
        }
        const Leap::Vector *velocityVector = hand.velocity();
        if(velocityVector) {
            _velocity = LeapVectorCreate(velocityVector->x, velocityVector->y, velocityVector->z);
        }

        const std::vector<Leap::Finger> leapFingers =
            hand.fingers();
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:leapFingers.size()];
            
        for (size_t i = 0; i < leapFingers.size(); ++i) {
            Leap::Finger finger = leapFingers[i];
            LeapFinger *leapFinger = [[LeapFinger alloc] initWithFinger:finger];
            [array addObject:leapFinger];
        }
        _fingers = [array copy];
        
        const Leap::Vector *normal = hand.normal();
        if(normal) {
            _normal = LeapVectorCreate(normal->x, normal->y, normal->z);
        }
        
        const Leap::Ball *ball = hand.ball();
        if(ball) {
            _ball = [[LeapBall alloc] initWithBall:*ball];
        }
    }
    
    return self;
}

- (NSString *)description {
    
    NSString *palmString = nil;
    NSString *velocityString = nil;
    if([self palm]) {
        palmString = NSStringFromLeapRay(*[self palm]);
    }
    if([self velocity]) {
        velocityString = NSStringFromLeapVector(*[self velocity]);
    }
    return [NSString stringWithFormat:@"Hand id: %ld\n\tPalm: %@\n\tVelocity: %@\n\tFingers count: %ld Ball: %@",
            [self id],
            palmString,
            velocityString,
            [self fingers].count,
            [self.ball description]];
}

- (void)dealloc {
    if(_palm) {
        delete _palm;
        _palm = NULL;
    }
    if(_velocity) {
        delete _velocity;
        _velocity = NULL;
    }
}
@end

#pragma mark - Frame

@interface LeapFrame() {
}
@end
@implementation LeapFrame

-(id)initWithFrame:(Leap::Frame)frame {
    self = [super init];
    if(self) {
        _id = frame.id();
        _timestamp = frame.timestamp();
        
        const std::vector<Leap::Hand>& hands = frame.hands();
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:hands.size()];
        for (size_t i = 0; i < hands.size(); ++i) {
            Leap::Hand hand = hands[i];            
            LeapHand *leapHand = [[LeapHand alloc] initWithHand:hand];
            [array addObject:leapHand];            
        }
        _hands = [array copy];
    }
    return self;
}

- (void)dealloc {
}

- (NSString *)description {
    NSUInteger fingerCount = 0;
    for(LeapHand *hand in [self hands]) {
        fingerCount += [[hand fingers] count];
    }
    return [NSString stringWithFormat:@"Frame id: %ld Hand Count: %ld Finger Count: %ld", [self id], [self hands].count, fingerCount];
}

@end

#pragma mark Listener and Controller

struct ListenerOpaque {
public:
    // Listener needs access to objc class for the delegation of methods
    ListenerOpaque(LeapListener *leapListener) : listener(leapListener) {
        
    }
    ListenerSubclass listener;
};

struct ControllerOpaque {
public:
    ControllerOpaque(ListenerOpaque *listener) : controller(&listener->listener) { };
    Leap::Controller controller;
};

// Controller


@interface LeapController() {
    ControllerOpaque *_controller;
}
-(id)initWithListener:(ListenerOpaque *)listener;

@end

@implementation LeapController
-(id)initWithListener:(ListenerOpaque *)listener {
    self = [super init];
    if(self) {
        _controller = new ControllerOpaque(listener);
    }
    return self;
}

- (LeapFrame *)frame {
    LeapFrame *value = [[LeapFrame alloc] initWithFrame:_controller->controller.frame()];
    return value;
}

- (LeapFrame *)frame:(int)frameHistory {
    LeapFrame *value = [[LeapFrame alloc] initWithFrame:_controller->controller.frame(frameHistory)];
    return value;
}
- (void)dealloc {
    if(_controller) {
        delete _controller;
        _controller = nil;
    }
}
@end

@implementation LeapListener

- (id)init {
    throw [NSException exceptionWithName:@"Invalid init" reason:@"Do not attempt to create LeapListener withou delegate" userInfo:nil];

}
- (id)initWithDelegate:(id<LeapDelegate>)delegate {
          //  controller:(ControllerOpaque)controller {
    self = [super init];
    if(self) {
        NSLog(@"Leap Listener");
        _delegate = delegate;
        _listener = new ListenerOpaque(self);
        _controller = [[LeapController alloc] initWithListener:_listener];
    }
    return self;
}

- (void)onInit {
    @autoreleasepool {
        [_delegate onInit:_controller];
    }
}
- (void)onConnect {
    @autoreleasepool {
        [_delegate onConnect:_controller];
    }
}

- (void)onDisconnect {
    @autoreleasepool {
        [_delegate onDisconnect:_controller];
    }
}
- (void)onFrame {
    @autoreleasepool {
        [_delegate onFrame:_controller];
    }
}

- (void)dealloc {
    delete _listener;
    _listener = NULL;
    _controller = nil;
}
@end


