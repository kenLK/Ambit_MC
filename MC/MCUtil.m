//
//  MCUtil.m
//  MC
//
//  Created by Ken on 2014/10/6.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import "MCUtil.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@interface NSString(MD5)

- (NSString *)MD5;

@end

@implementation MCUtil

-(NSString*)excPost:(NSString*)url:(NSString*)nameValuePairs{

    
    NSString* urlString = @"";
//    NSString* urlString = [[NSString alloc] initWithFormat:@"%@m/guest/uploadLoginInfo?type=%@&pushToken=%@&isJbRoot=%@&versionCode=%@&deviceId=%@&os=iOS&gameId=%@&gid=%@&phonemodel=%@&osversion=%@&serverId=%@&roleId=%@&logintime=%@&verify=%@&",[MPVarible getInstance].useServerURL, type, deviceToken,isJB?@"true":@"false", version, [MPKeyChainValue readUUID],gameID, gid, [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding], [UIDevice currentDevice].systemVersion,serverID,roleID,dateStr,verify];
    MCLogger(@"uploadDeviceInfo====>%@",urlString);
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] init];
    [urlrequest setTimeoutInterval:10];
    [urlrequest setURL:[NSURL URLWithString:urlString]];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    [NSURLConnection sendSynchronousRequest:urlrequest
                          returningResponse:&response
                                      error:&error];
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    
    
    return @"";
}

+(NSString *)hmac:(NSString *)plainText withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plainText cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    
    for (int i = 0; i < HMACData.length; ++i)
        HMAC = [HMAC stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];
    
    return HMAC;
}

-(NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i){
        [HMAC appendFormat:@"%02x", buffer[i]];
    }
    return HMAC;
}


- (NSString*)MD5:(NSString*)encodeSource
{
    // Create pointer to the string as UTF8
    const char *ptr = [encodeSource UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end


@implementation NSString(MD5)

- (NSString*)MD5
{
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
