//
//  WWFeedReader.m
//  iRedmine
//
//  Created by Thomas Stägemann on 22.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import "WWFeedReader.h"


@implementation WWFeedReader

@synthesize webData;
@synthesize rssParser;
@synthesize currentElement;
@synthesize currentDict;
@synthesize resultArray;

- (id)initWithRequest:(NSURLRequest *)request keyForItems:(NSString *)key arrayOfKeys:(NSArray *)keys delegate:(id)delegate
{	
	if (self = [super init]) 
	{
		_arrayOfKeys = [keys copy];
		_keyForItems	 = [key copy];
		
		resultArray = [[NSMutableArray alloc] init];
		webData		= [[NSMutableData  alloc] init];
		
		[self setRequest:request];
		[self setDelegate:delegate];
		[self read];
	}
	return self;
}

- (void)read
{
	[[[NSURLConnection alloc] initWithRequest:[self request] delegate:self] retain];	
}

#pragma mark Getter and setter methods

- (NSURLRequest *)request
{
	return _request;
}

- (void)setRequest:(NSURLRequest *)request
{
	_request = [request retain];
}

- (id)delegate
{
	return _delegate;
}

- (void)setDelegate:(id)delegate
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
    if (_delegate)
        [nc removeObserver:_delegate name:nil object:self];
	
    _delegate = delegate;
    
    // repeat  the following for each notification
    if ([_delegate respondsToSelector:@selector(feedReader:didEndWithResult:)])
	{
        [nc addObserver:_delegate selector:@selector(feedReader:didEndWithResult:) name:nil object:self];
	}
	
}

#pragma mark Delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser 
{
	NSLog(@"Found file and started parsing");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
	NSString * errorString = [NSString stringWithFormat:NSLocalizedString(@"Unable to download feed from web site (Error code %i: %@)",@"Unable to download feed from web site (Error code %i: %@)"), [parseError code],[parseError localizedDescription]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading content",@"Error loading content") message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
	[parser abortParsing];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	//NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
	
	if ([elementName isEqualToString:_keyForItems]) 
	{
		// clear out our story item caches...
		currentDict = [NSMutableDictionary dictionaryWithCapacity:[_arrayOfKeys count]];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{	
	if ([elementName isEqualToString:_keyForItems]) 
	{
		// save values to an item, then store that item into the array...	
		[resultArray addObject:currentDict];
		//NSLog(@"adding dictionary: %@",currentDict);
	}
	
	//NSLog(@"ended element: %@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if([_arrayOfKeys containsObject:currentElement])
	{
		//NSLog(@"found characters: %@", string);
		// save the characters for the current item...
		NSString * curr = [currentDict valueForKey:currentElement];
		if(curr != nil)
		{
			NSMutableString * currentString = [NSMutableString stringWithString:curr];
			[currentString appendString:string];
			[currentDict setValue:currentString forKey:currentElement];	
		}
		else
		{
			[currentDict setValue:string forKey:currentElement];	
		}
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser 
{
	//NSLog(@"parsing done!");
	
	// returns the result array;
	if ([_delegate respondsToSelector:@selector(feedReader:didEndWithResult:)])
	{
        [_delegate feedReader:self didEndWithResult:resultArray];
	}
    else
    { 
        [NSException raise:NSInternalInconsistencyException	format:@"Delegate doesn't respond to feedReader:didEndWithResult:"];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[webData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	
	NSString * xmlString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
	//NSLog(@"Data received:\n%@",xmlString);
	[xmlString release];
	
	[webData appendData:data];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[connection release];
	[webData release];
	
	NSLog(@"Connection error: %@",[error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	NSString * xmlString = [[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
	//NSLog(@"All data received:\n%@",xmlString);
	[xmlString release];
	
	if(rssParser)
	{
		[rssParser release];
	}
	
	rssParser = [[NSXMLParser alloc] initWithData:webData];
	[rssParser setDelegate:self];
	[rssParser setShouldResolveExternalEntities:YES];
	[rssParser parse];
	
	[connection release];
	[webData release];
}

- (void)dealloc 
{
	[webData release];
	[rssParser release];
	[currentElement release];
	[currentDict release];
	[resultArray release];
	[_request release];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
    if (_delegate)
	{
        [nc removeObserver:_delegate name:nil object:self];
	}
	
    [super dealloc];
}

@end
