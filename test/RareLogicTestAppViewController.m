//
//  RareLogicTestAppViewController.m
//  RareLogic
//
//  Created by Mark Northcott on 11-10-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RareLogicTestAppViewController.h"
#import "RareLogicEvent.h"

@implementation RareLogicTestAppViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)click {
    RareLogicEvent* event = [[RareLogicEvent alloc] init];
    
    [event set: @"content" andName: @"page" withStringValue: @"Blog Homepage"];
    [event set: @"content" andName: @"category" withStringValue: @"Blog Pages"];
    [event record];
    [event release];
}

@end
