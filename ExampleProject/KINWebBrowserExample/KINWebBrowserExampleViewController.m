//
//  KINWebBrowserExampleViewController.m
//  KINWebBrowserExample
//
//  Created by David Muir on 2/4/14.
//  Copyright (c) 2014 Kinwa, Inc. All rights reserved.
//

#import "KINWebBrowserExampleViewController.h"

#import "KINWebBrowserViewController.h"

@interface KINWebBrowserExampleViewController ()

@end

static NSString* const defaultAddress = @"http://www.apple.com";

@implementation KINWebBrowserExampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)pushButtonPressed:(id)sender {
    KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowserViewController];
    [self.navigationController pushViewController:webBrowser animated:YES];
    
    [webBrowser loadURLString:defaultAddress];

    
}

- (IBAction)presentButtonPressed:(id)sender {
    UINavigationController *webBrowserNavigationController = [KINWebBrowserViewController navigationControllerWithRootWebBrowserViewController];
    [self presentViewController:webBrowserNavigationController animated:YES completion:nil];
                                                              

    KINWebBrowserViewController *webBrowser = [webBrowserNavigationController rootWebBrowserViewController];
    [webBrowser loadURLString:defaultAddress];
}
@end
