//
//  ProjectTableController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 21.04.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeCell.h"
#import "ProjectViewController.h"
#import "IssueTableController.h"
#import "WWURL.h"

@interface ProjectTableController : UITableViewController 
{
	NSMutableArray * projectArray;
	UITableView * projectTable;
	ProjectViewController * projectViewController;
	IssueTableController * assignedIssuesViewController;
	IssueTableController * reportedIssuesViewController;	
	BadgeCell * badgeCell;
	NSDictionary * loginData;
	NSMutableArray *assignedIssues;
	NSMutableArray *reportedIssues;
}

@property(nonatomic,retain) NSMutableArray * projectArray;
@property(nonatomic,retain) IBOutlet UITableView * projectTable;
@property(nonatomic,retain) ProjectViewController * projectViewController;
@property(nonatomic,retain) IssueTableController * assignedIssuesViewController;
@property(nonatomic,retain) IssueTableController * reportedIssuesViewController;	
@property(nonatomic,retain) IBOutlet BadgeCell * badgeCell;
@property(nonatomic,retain) NSDictionary * loginData;
@property(nonatomic,retain) NSMutableArray * assignedIssues;
@property(nonatomic,retain) NSMutableArray * reportedIssues;

- (IBAction)fetchAssignedIssues:(id)sender;
- (IBAction)fetchReportedIssues:(id)sender;

@end
