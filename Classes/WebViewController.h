//
//  WebViewController.h
//  iRedmine
//
//  Created by Thomas Stägemann on 07.05.09.
//  Copyright 2009 Thomas Stägemann. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController 
{
	UITabBarItem * homeItem;
	UITabBarItem * safariItem;
	UIWebView * webView;
}

@property(nonatomic,retain) IBOutlet UITabBarItem * homeItem;
@property(nonatomic,retain) IBOutlet UITabBarItem * safariItem;
@property(nonatomic,retain) IBOutlet UIWebView * webView;

@end
