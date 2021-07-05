//
//  EasyPromise.m
//
//  Created by Ara Hovakimyan on 01/May/2021.
//  Copyright © 2021 Ara Hovakimyan. All rights reserved.
//
//

#import "EasyPromise.h"
#import <queue>

typedef void (^HandlerBox)(id);

typedef NS_ENUM(NSUInteger, PromiseState) {
    /** No listener has been set */
    None,
    
    /** Then listener has been set */
    Then,
    
    /** Error listener has been set */
    Catch
};

@implementation EasyPromise {
    
    // Result of the resolve or reject.
    id mResult;
    
    // Current state of the promise.
    PromiseState mState;
    
    std::queue<HandlerBox> mHandlerBoxes;
    
    unsigned int mID;
}

- (instancetype) init {
    static unsigned int identificator = 0;
    if (self = [super init]) {
        mState = None;
        mID = identificator++;
    }
    return self;
}

// Add handlers to the promise for running when  promise will be resolved/rejected
// or run immediately if promise already resolved/rejected and return the next promise.
- (EasyPromise*) thenHandler:(Handler)pThenHandler {

    // Create next promise in the chain
    EasyPromise *nextPromise = [[EasyPromise alloc] init];
    
    HandlerBox ThenHandlerBox = ^(id value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [nextPromise resolve:pThenHandler(value)];
            } @catch (NSException *ex) {
                [nextPromise reject:ex];
            }
        });
    };
    
    HandlerBox CatchHandlerBox = ^(id reason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [nextPromise reject:reason];
            } @catch (NSException *ex) {
                [nextPromise reject:ex];
            }
        });
    };
    
    @synchronized(self) {
        if (mState == Then) {
            ThenHandlerBox(mResult);
        } else if (mState == Catch) {
            CatchHandlerBox(mResult);
        } else {
            // We keep ThenHandlers pointers in an even index and the CatchHandler pointers in the odd index.
            mHandlerBoxes.push(ThenHandlerBox);
            mHandlerBoxes.push(CatchHandlerBox);
        }
    };
    return nextPromise;
}

// Add handlers to the promise for running when  promise will be resolved/rejected
// or run immediately if promise already resolved or rejected and return the next promise.
- (EasyPromise*) catchHandler:(Handler)pCatchHandler {
    // Create next promise in the chain
    EasyPromise *nextPromise = [[EasyPromise alloc] init];
    
    HandlerBox ThenHandlerBox = ^(id value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [nextPromise resolve:value];
            } @catch (NSException *ex) {
                [nextPromise reject:ex];
            }
        });
    };
    
    HandlerBox CatchHandlerBox = ^(id reason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [nextPromise resolve:pCatchHandler(reason)];
            } @catch (NSException *ex) {
                [nextPromise reject:ex];
            }
        });
    };
    
    @synchronized(self) {
        if (mState == Then) {
            ThenHandlerBox(mResult);
        } else if (mState == Catch) {
            CatchHandlerBox(mResult);
        } else {
             // We keep ThenHandlers pointers in an even index and the CatchHandler pointers in the odd index.
            mHandlerBoxes.push(ThenHandlerBox);
            mHandlerBoxes.push(CatchHandlerBox);
        }
    };
    return nextPromise;
}

- (EasyPromise*(^)(Handler pThenHandler)) then {
    return ^EasyPromise*(Handler pThenHandler) {
        return [self thenHandler:pThenHandler];
    };
}

- (EasyPromise*(^)(Handler pCatchHandler)) catch {
    return ^EasyPromise*(Handler pCatchHandler) {
        return [self catchHandler:pCatchHandler];
    };
}

- (EasyPromise*)then:(Handler)pHandler {
    return [self thenHandler:pHandler];
}

- (EasyPromise*)catch:(Handler)pHandler {
    return [self catchHandler:pHandler];
}

- (void) resolve:(id)value {
    @synchronized(self) {
        if (mState != None) {
            @throw [[NSException alloc] initWithName:@"Has Resolution" reason:@"Already resolved or rejected." userInfo:nil];
        }
        
        if (value == self) {
            @throw  [[NSException alloc] initWithName:@"Type Error" reason:@"Type Error" userInfo:nil];
        }
        
        if ([value isKindOfClass:EasyPromise.class]) {

            [(EasyPromise*)value thenHandler:^(id value) {
                [self resolve:value];
                return [NSNull null];
            }];
            
            [(EasyPromise*)value catchHandler:^(id value) {
                [self reject:value];
                return [NSNull null];
            }];
            return;
        }
        
        mState = Then;
        mResult = value;
        
        while ( ! mHandlerBoxes.empty()) {
            HandlerBox handle = mHandlerBoxes.front();
            handle(mResult);
            mHandlerBoxes.pop();
            mHandlerBoxes.pop();
        }
    }
}

- (void) reject:(id)reason {
    @synchronized(self) {
        if (mState != None) {
            @throw [[NSException alloc] initWithName:@"Has Resolution" reason:@"Already resolved or rejected" userInfo:nil];
        }
        mState = Catch;
        mResult = reason;
        
        while ( ! mHandlerBoxes.empty()) {
            mHandlerBoxes.pop();
            HandlerBox handle = mHandlerBoxes.front();
            handle(mResult);
            mHandlerBoxes.pop();
        }
    }
}

@end
