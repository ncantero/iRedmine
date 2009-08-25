//
//  WWURL.m
//  iRedmine
//
//  Created by Thomas Stägemann on 22.07.09.
//  Copyright 2009 Weißhuhn & Weißhuhn. All rights reserved.
//

#import "WWURL.h"


@implementation WWURL

+(NSString *)encode:(NSString *)url
{
	NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,
							@"$" , @"," , @"[" , @"]",
							@"#", @"!", @"'", @"(", 
							@")", @"*", nil];
	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
							 @"%3A" , @"%40" , @"%26" ,
							 @"%3D" , @"%2B" , @"%24" ,
							 @"%2C" , @"%5B" , @"%5D", 
							 @"%23", @"%21", @"%27",
							 @"%28", @"%29", @"%2A", nil];
		
    NSMutableString *temp = [url mutableCopy];
	
    int i;
    for(i = 0; i < [escapeChars count]; i++)
    {
		
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
    }
		
    return [NSString stringWithString: temp];	
}

@end
