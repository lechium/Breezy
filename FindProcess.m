


#import "FindProcess.h"
#import <objc/runtime.h>

#include <stdio.h>
#include <stdint.h>
#include <mach/mach.h>
#include <dlfcn.h>
#include <pthread.h>
#include <unistd.h>

#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#import <objc/runtime.h>
#include <sys/cdefs.h>
#include <sys/types.h>
#include <sys/param.h>
#include <mach/boolean.h>
#include <dispatch/dispatch.h>
#include <stdlib.h>
#include <spawn.h>
#include <assert.h>
#import <Foundation/Foundation.h>
#import <Security/Security.h>


#define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);

extern char*** _NSGetEnviron(void);
extern int proc_listallpids(void*, int);
extern int proc_pidpath(int, void*, uint32_t);
static int process_buffer_size = 4096;

@implementation FindProcess

+ (int)pidFromItemDescription:(NSString *)desc {
    NSScanner *theScanner = nil;
    NSString *text = nil;
    //NSString *myString = @"<OS_xpc_connection: <connection: 0x133dc3790> { name = com.apple.sharingd.peer.0x133dc3790, listener = false, pid = 3731, euid = 501, egid = 501, asid = 0 }>";
    theScanner = [NSScanner scannerWithString:desc];
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"pid =" intoString:NULL] ;
        
        // find end of tag
        [theScanner scanUpToString:@"," intoString:&text] ;
    }
    NSString *clean = [text stringByReplacingOccurrencesOfString:@"pid = " withString:@""];
    NSLog(@"clean: %@", clean);
    return [clean intValue];
}

+ (boolean_t) process:(pid_t)ppid matches:(const char* )name {
    //pid_t *pid_buffer;
    char path_buffer[MAXPATHLEN];
    boolean_t res = FALSE;
    int ret = proc_pidpath(ppid, (void*)path_buffer, sizeof(path_buffer));
    if(ret < 0) {
        printf("(%s:%d) proc_pidinfo() call failed.\n", __FILE__, __LINE__);
    }
    
    if(strstr(path_buffer, name)) {
        res = TRUE;
    }
    
    return res;
}
//plucked and modified from AppSyncUnified

+ (pid_t) find_process:(const char*) name {
    pid_t *pid_buffer;
    char path_buffer[MAXPATHLEN];
    int count, i, ret;
    boolean_t res = FALSE;
    pid_t ppid_ret = 0;
    pid_buffer = (pid_t*)calloc(1, process_buffer_size);
    assert(pid_buffer != NULL);
    
    count = proc_listallpids(pid_buffer, process_buffer_size);
    if(count) {
        for(i = 0; i < count; i++) {
            pid_t ppid = pid_buffer[i];
            
            ret = proc_pidpath(ppid, (void*)path_buffer, sizeof(path_buffer));
            if(ret < 0) {
                printf("(%s:%d) proc_pidinfo() call failed.\n", __FILE__, __LINE__);
                continue;
            }
            if (strncmp(path_buffer, name, strlen(path_buffer)) == 0){
                res = TRUE;
                ppid_ret = ppid;
                break;
            }
            /*
            if(strstr(path_buffer, name)) {
                res = TRUE;
                ppid_ret = ppid;
                break;
            }*/
        }
    }
    
    free(pid_buffer);
    return ppid_ret;
}

@end



