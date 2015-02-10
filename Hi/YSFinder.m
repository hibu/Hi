//
//  YSFinder.m
//  Hi
//
//  Created by Marc Palluat de Besset on 09/02/2015.
//  Copyright (c) 2015 hibu. All rights reserved.
//

#import "YSFinder.h"
#include <netdb.h>
#include <arpa/inet.h>

extern BOOL done;

@interface YSFinder () <NSNetServiceDelegate>

@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, strong) NSMutableArray *netServices;

@end

@implementation YSFinder

- (instancetype)initWithService:(NSString*)service host:(NSString*)host {
    if (( self = [super init] )) {
        self.service = service;
        self.host = host;
        self.netServices = [NSMutableArray new];
    }
    return self;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    
    if ([self.service isEqualToString:@"*"]) {
        aNetService.delegate = self;
        [aNetService resolveWithTimeout:10.0];
        [self.netServices addObject:aNetService];
    }
    else if ([aNetService.name isEqualToString:self.service]) {
        aNetService.delegate = self;
        [aNetService resolveWithTimeout:10.0];
        [self.netServices addObject:aNetService];
    }
}

- (void)netServiceDidResolveAddress:(NSNetService *)aNetService {
    if (!self.host || [[aNetService.hostName lowercaseString] containsString:[self.host lowercaseString]]) {
        struct hostent *hostentry;
        hostentry = gethostbyname(aNetService.hostName.UTF8String);
        if (hostentry) {
            char *ipbuf = inet_ntoa(*((struct in_addr *)hostentry->h_addr_list[0]));
            
            if ([self.service isEqualToString:@"*"]) {
                printf("Service: %s type: %s domain: %s host: %s address: %s port: %ld\n", aNetService.name.UTF8String, aNetService.type.UTF8String, aNetService.domain.UTF8String, aNetService.hostName.UTF8String, ipbuf, (long)aNetService.port );
            } else {
                printf("%s:%ld\n",ipbuf, (long)aNetService.port);
                done = YES;
            }
        }
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"error %@", errorDict);
}

@end
