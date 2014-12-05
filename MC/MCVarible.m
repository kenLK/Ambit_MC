//
//  MCVarible.m
//  MC
//
//  Created by Ken on 2014/10/3.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import "MCVarible.h"

@interface NSString(MD5)

- (NSString *)MD5;

@end


@implementation MCVarible


static MCVarible *instance =nil;
+(MCVarible *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            
            instance= [MCVarible new];
            
        }
        
    }
    return instance;
}


- (BOOL) initURLList {
    self.useServerURL = [[NSMutableString alloc] init];
    NSDictionary* urlList = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"http://210.80.86.180:8081/mcfe/", @"DEV",
                             @"http://test.smartid.com.tw/mcfe/", @"SIT",
                             @"http://test.smartid.com.tw/mcfe/", @"UAT",
                             @"http://test.smartid.com.tw/mcfe/", @"UAT2",
                             @"https://www.smartid.com.tw/mcfe/", @"PROD",
                             @"http://10.24.100.180/dev", @"LOCAL",
                             @"http://10.24.100.180:8081/mcfe/", @"DEVTEST",
                             nil];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MCCONFIG" ofType:@"plist"];
    if (plistPath == nil) {
        MCLogger(@"<Parameter Setting> Properity list not found [error code:101]");
        return NO;
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    if ([[dict objectForKey:@"SERVER"] isEqualToString:@"LOCAL"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"DEV"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"SIT"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"UAT"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"UAT2"]|| [[dict objectForKey:@"SERVER"] isEqualToString:@"PROD"]) {
        self.useServerURL = [urlList objectForKey:[dict objectForKey:@"SERVER"]];
        MCLogger(@"<Parameter Setting> Use URL: %@", self.useServerURL);
    } else {
        self.useServerURL = [urlList objectForKey:@"DEVTEST"];
        MCLogger(@"<Parameter Setting> Use URL: %@", self.useServerURL);
    }
    
    return YES;
}

-(NSString*)sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(NSInteger i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}




@end
