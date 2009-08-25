//
//  IssueTableController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 01.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubtitleCell.h"
#import "RMParser.h"
#import "WWFeedReader.h"
#import "WWURL.h"
#import "WebViewController.h"

@interface IssueTableController : UITableViewController {
	UITableView * issuesTable;
	NSArray * _issues;
	UIActivityIndicatorView * activityIndicator;	
	SubtitleCell * subtitleCell;
	NSDictionary * _loginData;
	WebViewController * webViewController;
}

@property(nonatomic,retain) IBOutlet UITableView * issuesTable;
@property(nonatomic,retain) NSArray * _issues;
@property(nonatomic,retain) UIActivityIndicatorView * activityIndicator;
@property(nonatomic,retain) IBOutlet SubtitleCell * subtitleCell;
@property(nonatomic,retain) NSDictionary * _loginData;
@property(nonatomic,retain) WebViewController * webViewController;

+ (id)initWithArray:(NSArray *)array title:(NSString*)title loginData:(NSDictionary*)loginData;
- (void)setIssues:(NSArray*)array;
- (void)setLoginData:(NSDictionary*)loginData;

@end
