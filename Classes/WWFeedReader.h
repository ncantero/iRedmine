//
//  WWFeedReader.h
//  iRedmine
//
//  Created by Thomas Stägemann on 22.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WWFeedReader : NSObject
{
	NSMutableData * webData;
	NSXMLParser * rssParser;
	NSString * currentElement;
	NSMutableDictionary * currentDict;
	NSMutableArray * resultArray;
	
	id _delegate;
	NSString * _keyForItems;
	NSArray * _arrayOfKeys;
	NSURLRequest * _request;
}

@property(nonatomic,retain) NSXMLParser * rssParser;
@property(nonatomic,retain) NSMutableData * webData;
@property(nonatomic,retain) NSString * currentElement;
@property(nonatomic,retain) NSMutableDictionary * currentDict;
@property(nonatomic,retain) NSMutableArray * resultArray;

- (id)initWithRequest:(NSURLRequest *)request keyForItems:(NSString *)key arrayOfKeys:(NSArray *)keys delegate:(id)delegate;

- (void)read;

- (NSURLRequest *)request;
- (void)setRequest:(NSURLRequest *)request;

- (id)delegate;
- (void)setDelegate:(id)delegate;

@end

@interface NSObject (WWFeedReaderDelegate)

- (void)feedReader:(WWFeedReader *)feedReader didEndWithResult:(NSArray *)result;

@end
