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
    //NSArray *gravityX = @[ @0.0f, @0.0f, @0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f ];
    //NSArray *gravityY = @[ @0.0f, @0.0f, @0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f ];
    //NSArray *gravityZ = @[ @0.0f, @0.0f, @0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f,@0.0f ];
   
   

    if([motionManager isDeviceMotionAvailable] == YES){
        motionManager.deviceMotionUpdateInterval = 0.1;
        
        int length = 10;

        NSMutableArray *gravityX = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *gravityY = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *gravityZ = [[NSMutableArray alloc] initWithCapacity:0];
        //NSArray gravityX[10];
        /*double gravityY[10];
        double gravityZ[10];

        double *ptrX = gravityX;
        double *ptrY = gravityY;
        double *ptrZ = gravityZ;*/

         __block NSInteger index = 0;

         __block NSInteger growingSize = 0;
        
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
            NSString *orientation;

            [gravityX addObject:[NSNumber numberWithDouble:data.gravity.x]];
            [gravityY addObject:[NSNumber numberWithDouble:data.gravity.y]];
            [gravityZ addObject:[NSNumber numberWithDouble:data.gravity.z]];
            
            
            
/*
            ptrX[index] = data.gravity.x;
            ptrY[index] = data.gravity.y;
            ptrZ[index] = data.gravity.z;

            NSLog(@"index %ld", index);
            NSLog(@"ptrX[index] %f", ptrX[index]);
*/
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
                NSLog(@"gravityX[%d] %f", i, [[gravityX objectAtIndex:i]doubleValue]);
                
                gX+= [[gravityX objectAtIndex:i]doubleValue];
                gY+= [[gravityY objectAtIndex:i]doubleValue];
                gZ+= [[gravityZ objectAtIndex:i]doubleValue];
               /* NSLog(@"ptrX[%d] %f", i, ptrX[i]);
                gX+= ptrX[i];
                gY+= ptrY[i];
                gZ+= ptrZ[i];*/
            }

            gX = gX/growingSize;
            gY = gY/growingSize;
            gZ = gZ/growingSize;


            index = index + 1;

            if(index>=10){
                index = 0;
            }



            NSLog(@"gravity.x %f", data.gravity.x);
            NSLog(@"*********");
            
            NSLog(@"gX %f", gX);
            NSLog(@"gY %f", gY);
            NSLog(@"gZ %f", gZ);
            NSLog(@"*********");
            
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


