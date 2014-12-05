//
//  MCLog.h
//  MC
//
//  Created by Ken on 2014/10/3.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MCLogger(s,...) \
[MCLog logFile:__FILE__ lineNumber:__LINE__ \
format:(s),##__VA_ARGS__]

@interface MCLog : NSObject

+ (void) log:(NSString*) logStr;


+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber
        format:(NSString*)format, ...;
+(void)setLogOn:(BOOL)logOn;

@end
