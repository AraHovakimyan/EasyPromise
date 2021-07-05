//
//  main.m
//  EasyPromise
//
//   Created by Ara Hovakimyan on 01/May/2021.
//

#import <Foundation/Foundation.h>
#import "EasyPromise.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        EasyPromise*promise = [[EasyPromise alloc] init];
        promise.then(^(NSString* result) {
            NSLog(@"Promise successful resolved with %@", result);
            
            // Need to return something to avoid crashes in iOS 10 or older versions.
            return @"result-1";
        }).then(^(NSString* result) {
            NSLog(@"Promise successful resolved with %@", result);
            
            // Need to return something to avoid crashes in iOS 10 or older versions.
            return [NSNull null];
        }).catch(^(NSString* reason) {
            NSLog(@"Promise successful resjected with %@", reason);
            
            // Need to return something to avoid crashes in iOS 10 or older versions.
            return [NSNull null];
        });
        
        [promise resolve:@"result"];
        
        
        
        
        // _________________________________________________
        // _____________ Objective-C style   ________________
        EasyPromise *promiseOther = [[EasyPromise alloc] init];

         [[[promiseOther then:^(id result) {
            // Waiting for a successfully completed process to print a string containing the result of the process.
            NSLog(@"Success with result : %@", result); // Success with result : result-0
            return @"result_1";
        }]
        then:^(id result_1) {
            // Waiting for the previous process to complete successfully to print a string containing the result of the previous process.
            NSLog(@"Success with result : %@", result_1); // Success with result : result-1
             
            // Need to return something to avoid crashes in iOS 10 or older versions.
            return  [NSNull null];
        }]
        catch:^(id reason) {
            // Waiting for errors as a string containing the reason for the error.
            // This line is entered when a Howar error occurs, in other words,
            // when the function "reject" will be called, the reason for the error will be passed to it as an argument.
            NSLog(@"Error error with reason : %@", reason);

            // Need to return something to avoid crashes in iOS 10 or older versions.
            return  [NSNull null];

        }];
        
        [promiseOther resolve:@"result"];
    }
    return 0;
}
