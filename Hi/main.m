//
//  main.m
//  Hi
//
//  Created by Marc Palluat de Besset on 09/02/2015.
//  Copyright (c) 2015 hibu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFinder.h"

BOOL done = NO;

NSString* Bold(NSString *string) {
    return [NSString stringWithFormat:@"%c[1m%@%c[0m", 033, string, 033];
}

void StdOut(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSData *data = [formattedString dataUsingEncoding:NSUTF8StringEncoding];
    NSFileHandle *outputFileHandle = [NSFileHandle fileHandleWithStandardOutput];
    [outputFileHandle writeData:data];
}

void help(void) {
    StdOut(Bold(@"\nHi (Bonjour services finder) tool © 2015 YELL\n\n"));
    
    StdOut(Bold(@"-service"));
    StdOut(@" Name of the service to find\n");
    
    StdOut(Bold(@"-type"));
    StdOut(@" Type of the service. Defaults to _http._tcp\n");
    
    StdOut(Bold(@"-domain"));
    StdOut(@" Domain where to look for. Defaults to local.\n");
    
    StdOut(Bold(@"-host"));
    StdOut(@" Host name of the phone the service is running on.\n");
}


int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        
        [[[NSProcessInfo processInfo] arguments] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *arg = obj;
            if ([arg isEqualToString:@"--help"]) {
                help();
                exit(0);
            }
        }];
        
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
        
        NSString *service = [args stringForKey:@"service"];
        if (!service || service.length == 0) {
            service = @"*";
        }
        
        NSString *type = [args stringForKey:@"type"];
        if (!type || type.length == 0) {
            type = @"_http._tcp";
        }
        
        NSString *domain = [args stringForKey:@"domain"];
        if (!domain || domain.length == 0) {
            domain = @"local.";
        }
        
        NSString *host = [args stringForKey:@"host"];
        if (!host || host.length == 0) {
            host = nil;
        }

        
        YSFinder *finder = [[YSFinder alloc] initWithService:service host:host];

        NSNetServiceBrowser *browser = [[NSNetServiceBrowser alloc] init];
        browser.delegate = finder;
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        
        [browser searchForServicesOfType:type inDomain:domain];
        [browser scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
        
        if ([service isEqualToString:@"*"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done = YES;
            });
        }
        
        while( !done ) {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
        }

        [browser stop];
    }
    return 0;
}
