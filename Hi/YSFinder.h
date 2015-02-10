//
//  YSFinder.h
//  Hi
//
//  Created by Marc Palluat de Besset on 09/02/2015.
//  Copyright (c) 2015 hibu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSFinder : NSObject <NSNetServiceBrowserDelegate>

- (instancetype)initWithService:(NSString*)service host:(NSString*)host;

@end
