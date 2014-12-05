//
//  MCLog.m
//  MC
//
//  Created by Ken on 2014/10/3.
//  Copyright (c) 2014年 Ken. All rights reserved.
//

#import "MCLog.h"

@implementation MCLog


static BOOL __MLogOn=NO;


-(id) init
{
    self = [super init];
    if(self)
    {
        //do something
    }
    return self;
}

+ (void) log:(NSString*) logStr {
    
    
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MCCONFIG" ofType:@"plist"];
    if (plistPath == nil) {
        NSLog(@"<Parameter Setting> Properity list not found");
        //        return NO;
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    
    if ([[dict objectForKey:@"SERVER"] isEqualToString:@"LOCAL"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"DEV"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"SIT"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"UAT"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"UAT2"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"DEVTEST"] ) {
        NSLog(@"MPLog >>>>> %@",logStr);
    }
}

+(void)initialize
{
    char * env=getenv("MLogOn");
    if(strcmp(env==NULL?"":env,"NO")!=0)
        __MLogOn=YES;
}

+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber
        format:(NSString*)format, ...;
{
    va_list ap;
    NSString *print,*file;
    if(__MLogOn==NO)
        return;
    va_start(ap,format);
    file=[[NSString alloc] initWithBytes:sourceFile
                                  length:strlen(sourceFile)
                                encoding:NSUTF8StringEncoding];
    print=[[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    //MCLogger handles synchronization issues
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MCCONFIG" ofType:@"plist"];
    if (plistPath == nil) {
        NSLog(@"<Parameter Setting> Properity list not found");
        //        return NO;
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    
    if ([[dict objectForKey:@"SERVER"] isEqualToString:@"LOCAL"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"DEV"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"SIT"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"UAT"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"UAT2"] || [[dict objectForKey:@"SERVER"] isEqualToString:@"DEVTEST"] ) {
        
        NSLog(@"%s:%d %@",[[file lastPathComponent] UTF8String],
              lineNumber,print);
    }
    
    return;
}
+(void)setLogOn:(BOOL)logOn
{
    __MLogOn=logOn;
}


@end
