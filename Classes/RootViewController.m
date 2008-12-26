/*

File: RootViewController.m
Abstract: Creates a table view and serves as its delegate and data source.

Version: 2.6

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import "RootViewController.h"
#import "AccountsController.h"
#import "InstanceGroupSetViewController.h"
#import "AddAccountViewController.h"

@implementation RootViewController

@synthesize accountsController, toolbar, activityIndicator;

- (void)viewDidLoad {
	self.title = @"AWS Accounts";
	self.navigationItem.rightBarButtonItem = self.editButtonItem;

	// Set up toolbar.
	toolbar = [[UIToolbar alloc] init];
	toolbar.barStyle = UIBarStyleDefault;
	[toolbar sizeToFit];
	CGFloat toolbarHeight = [toolbar frame].size.height;
	CGRect rootViewBounds = self.parentViewController.view.bounds;
	CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
	CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
	CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
	[toolbar setFrame:rectArea];	

	UIBarButtonItem* refresh_button = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
										target:self action:@selector(refreshButtonHandler:)];
	UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem* add_account_button = [[UIBarButtonItem alloc]
										   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
										   action:@selector(addButtonHandler:)];
	[toolbar setItems:[NSArray arrayWithObjects:refresh_button,spacer,add_account_button,nil]];
	[refresh_button release];
	[spacer release];
	[add_account_button release];
	[self.navigationController.view addSubview:toolbar];

	// Add spinner/activity indicator.
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	CGFloat spinnerWidth = CGRectGetWidth(activityIndicator.bounds);
	rectArea = CGRectMake(rootViewWidth/2 - spinnerWidth/2, rootViewHeight/2 - spinnerWidth/2, spinnerWidth, spinnerWidth);
	[activityIndicator setFrame:rectArea];
	[self.navigationController.view addSubview:activityIndicator];

	self.tableView.allowsSelectionDuringEditing = TRUE;
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)add {
	[self addAccount];
}

- (IBAction)addButtonHandler:(id)sender {
	[[self.navigationController topViewController] add];
}

- (IBAction)refreshButtonHandler:(id)sender {
	[[self.navigationController topViewController] refresh];
}

- (void)refresh {
	[self.tableView reloadData];
}

- (void)addAccount {
	AddAccountViewController* c = [[AddAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
	c.accountsController = accountsController;
	[[self navigationController] pushViewController:c animated:YES];
	[c release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [accountsController countOfList];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	AWSAccount* itemAtIndex = [accountsController objectInListAtIndex:indexPath.row];
	cell.text = [itemAtIndex name];
	cell.hidesAccessoryWhenEditing = NO;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.editing) {
		AddAccountViewController* c = [[AddAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
		c.accountsController = accountsController;
		c.account = [accountsController objectInListAtIndex:indexPath.row];
		[[self navigationController] pushViewController:c animated:YES];
		[c release];
	} else {
		AWSAccount* acct = [accountsController objectInListAtIndex:indexPath.row];
		EC2DataController* ec2Ctrl = [accountsController ec2ControllerForAccount:[acct name]];
		InstanceGroupSetViewController* igsvc = [[InstanceGroupSetViewController alloc]
												 initWithStyle:UITableViewStylePlain
												 account:acct
												 ec2Controller:ec2Ctrl];
	//	igsvc.dataController = [[InstanceGroupSetDataController alloc] initWithAccount:acct viewController:igsvc ec2Controller:ec2Ctrl];

		[[self navigationController] pushViewController:igsvc animated:YES];
		[igsvc release];
	}
}

- (void)dealloc {
    [accountsController release];
    [super dealloc];
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath { 
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	// Remove this account.
	[accountsController removeAccountAtIndex:indexPath.row];
	[self.tableView reloadData];
}

@end
