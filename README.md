# EasyPromise
The EasyPromise Implementation

# About EasyPromise
This project demonstrates the conceptual and fundamental characteristics of a Promise implementation. Can be used for educational purposes. It can also be used to implement commercial logic.

## Examples

    EasyPromise *promise = [[EasyPromise alloc] init];
    promise
    .then(^(NSString* result) {
        // Waiting for a successfully completed process to print a string containing the result of the process.
        NSLog(@"Success with result : %@", result); // Success with result : result-0
        return @"result-1";
    })
    .then(^(NSString* result) {
        // Waiting for the previous process to complete successfully to print a string containing the result of the previous process.
        NSLog(@"Success with result : %@", result); // Success with result : result-1
        
        // Need to return something.
        return  [NSNull null];;
    })
    .catch(^(NSString* reason) {
        // Waiting for errors as a string containing the reason for the error. 
        // This line is entered when a error occurs, in other words, 
        // when the function "reject" will be called, the reason for the error will be passed to it as an argument.
        NSLog(@"Error error with reason : %@", reason);
        
        // Need to return something.
        return [NSNull null];
    })
    [promise resolve:@"result-1"]; //@"result-0" of type NSString as resolved value.
    
### OR in Objective-C style
    
    EasyPromise *promise = [[EasyPromise alloc] init];
    
    [[[promise then:^(id result) {
        // Waiting for a successfully completed process to print a string containing the result of the process.
        NSLog(@"Success with result : %@", result); // Success with result : result-0
        return @"result-1";
    }]
    then:^(id result) {
        // Waiting for the previous process to complete successfully to print a string containing the result of the previous process.
        NSLog(@"Success with result : %@", result); // Success with result : result-1
        
        // Need to return something.
        return  [NSNull null];
    }]
    catch:^(NSString* reason) {
        // Waiting for errors as a string containing the reason for the error.
        // This line is entered when a error occurs, in other words,
        // when the function "reject" will be called, the reason for the error will be passed to it as an argument.
        NSLog(@"Error error with reason : %@", reason);
        
        // Need to return something.
        return [NSNull null];

    }];
    
    [promise resolve:@"result-1"];
    
### OR in Swift
    
    let promise = EasyPromise()
    promise.then({
        result in
        // Waiting for a successfully completed process to print a string containing the result of the process.
        print("Success with result : ", result)
        return  "result-2"
    }).then({
        result in
        // Waiting for a successfully completed process to print a string containing the result of the process.
        print("Success with result : ", result)
 
        // Need to return something.
        return  NSNull()
    }).catch({
        reason in
        // Waiting for errors as a string containing the reason for the error.
        // This line is entered when a error occurs, in other words,
        // when the function "reject" will be called, the reason for the error will be passed to it as an argument.
        print("Error error with reason : ", reason)
 
        // Need to return something.
        return NSNull()
    })
 
    promise.resolve("result-1");
