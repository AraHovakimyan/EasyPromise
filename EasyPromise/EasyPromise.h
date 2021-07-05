//
//  EasyPromise.h
//
//  Created by Ara Hovakimyan on 01/May/2021.
//  Copyright © 2021 Ara Hovakimyan. All rights reserved.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable (^Handler)(id);

@interface EasyPromise: NSObject

/**
 * Resolved the promise with the provided value
*/
- (void) resolve:(id _Nullable)value;

/**
 * Rejects the promise with the provided value
*/
- (void) reject:(id _Nullable)reason;


/**
 * @return the next promise in the chain
*/
- (EasyPromise*(^)(Handler)) then;


/**
 * @return the next promise in the chain
*/
- (EasyPromise*(^)(Handler)) catch;

/**
 *  To support Objective-C interface
 *  @param pHandler the Handler
 *  @return the next promise in the chain
*/
- (EasyPromise*)then:(Handler)pHandler;

/**
 *  To support Objective-C interface
 *  @param pHandler the Handler
 *  @return the next promise in the chain
*/
- (EasyPromise*)catch:(Handler)pHandler;

@end
NS_ASSUME_NONNULL_END
