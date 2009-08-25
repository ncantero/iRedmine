//
//  ProjectViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 14.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IssueTableController.h"
#import "WWURL.h"

@interface ProjectViewController : UIViewController <UITabBarDelegate> 
{
	NSMutableDictionary * project;
	UITabBarItem * homeItem;
	UITabBarItem * issuesItem;
	UITabBarItem * activityItem;
	UILabel * titleLabel;
	UILabel * dateLabel;
	UIWebView * descriptionText;
	NSDictionary * loginData;
}

@property(nonatomic,retain) NSMutableDictionary * project;
@property(nonatomic,retain) IBOutlet UITabBarItem * homeItem;
@property(nonatomic,retain) IBOutlet UITabBarItem * issuesItem;
@property(nonatomic,retain) IBOutlet UITabBarItem * activityItem;
@property(nonatomic,retain) IBOutlet UILabel * titleLabel;
@property(nonatomic,retain) IBOutlet UILabel * dateLabel;
@property(nonatomic,retain) IBOutlet UIWebView * descriptionText;
@property(nonatomic,retain) NSDictionary * loginData;

- (IBAction)fetchIssues:(id)sender;
- (IBAction)fetchActivities:(id)sender;

@end
