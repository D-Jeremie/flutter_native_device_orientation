#import "SensorListener.h"

@implementation SensorListener {
    CMMotionManager* motionManager;
    NSString* lastOrientation;
}

- (void)initMotionManager {
    if (!motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
}

- (void)startOrientationListener:(void (^)(NSString* orientation)) orientationRetrieved {
    [self initMotionManager];

    if([motionManager isDeviceMotionAvailable] == YES){
        motionManager.deviceMotionUpdateInterval = 0.1;
        
        int length = 10;

        NSMutableArray *gravityX = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *gravityY = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *gravityZ = [[NSMutableArray alloc] initWithCapacity:0];

         __block NSInteger index = 0;

         __block NSInteger growingSize = 0;
        
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
            NSString *orientation;

            [gravityX addObject:[NSNumber numberWithDouble:data.gravity.x]];
            [gravityY addObject:[NSNumber numberWithDouble:data.gravity.y]];
            [gravityZ addObject:[NSNumber numberWithDouble:data.gravity.z]];
            
            

            growingSize = growingSize + 1;
            if(growingSize>length){
                growingSize = length;
                [gravityX removeObjectAtIndex:0];
                [gravityY removeObjectAtIndex:0];
                [gravityZ removeObjectAtIndex:0];
            }

            float gX = 0.0;
            float gY = 0.0;
            float gZ = 0.0;

            for(int i=0; i<growingSize; i++){
                gX+= [[gravityX objectAtIndex:i]doubleValue];
                gY+= [[gravityY objectAtIndex:i]doubleValue];
                gZ+= [[gravityZ objectAtIndex:i]doubleValue];
            }

            gX = gX/growingSize;
            gY = gY/growingSize;
            gZ = gZ/growingSize;


            index = index + 1;

            if(index>=10){
                index = 0;
            }
            
            if(fabs(gZ)>fabs(gY) && fabs(gZ)>fabs(gX)){
                orientation = UNKNOWN;
            }
            else if(fabs(gX)>fabs(gY)){
                // we are in landscape-mode
                if(gX>=0){
                    orientation = LANDSCAPE_RIGHT;
                }
                else{
                    orientation = LANDSCAPE_LEFT;
                }
            }
            else{
                // we are in portrait mode
                if(gY>=0){
                    orientation = PORTRAIT_DOWN;
                }
                else{
                    orientation = PORTRAIT_UP;
                }
            }

            if (self->lastOrientation == nil || ![orientation isEqualToString:(self->lastOrientation)]) {
                self->lastOrientation = orientation;
                orientationRetrieved(orientation);
            }
        }];
    }
}

- (void) getOrientation:(void (^)(NSString* orientation)) orientationRetrieved {
    
    [self startOrientationListener:^(NSString *orientation) {
        orientationRetrieved(orientation);

        // we have received a orientation stop the listener. We only want to return one orientation
        [self stopOrientationListener];
    }];
}

- (void)stopOrientationListener {
    if (motionManager != NULL && [motionManager isDeviceMotionActive] == YES) {
        [motionManager stopDeviceMotionUpdates];
    }
}


@end


