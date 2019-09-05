//
//  FindProcess.h
//  
//
//  Created by Kevin Bradley on 5/20/19.
//

#import <Foundation/Foundation.h>

#define OurLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);

@interface FindProcess : NSObject
+ (int)pidFromItemDescription:(NSString *)desc;
+ (pid_t) find_process:(const char*) name;
+ (boolean_t) process:(pid_t)ppid matches:(const char* )name;
+ (void)classDumpObject:(id)obj;
@end


