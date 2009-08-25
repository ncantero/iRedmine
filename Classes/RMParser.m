//
//  WWDate.m
//  iRedmine
//
//  Created by Thomas Stägemann on 09.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "RMParser.h"


@implementation RMParser

+ (NSDate *)dateWithString:(NSString *)string
{
	return [NSDate dateWithString:[[string stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByReplacingOccurrencesOfString:@"+" withString:@" +"]];
}

@end
