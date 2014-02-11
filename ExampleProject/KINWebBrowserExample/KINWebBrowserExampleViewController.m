//
//  KINWebBrowserExampleViewController.m
//
//  KINWebBrowser
//
//  Created by David F. Muir V
//  dfmuir@gmail.com
//  Co-Founder & Engineer at Kinwa, Inc.
//  http://www.kinwa.co
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 David Muir
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import "KINWebBrowserExampleViewController.h"


@interface KINWebBrowserExampleViewController ()

@end

static NSString *const defaultAddress = @"http://www.apple.com/";

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
    [self.navigationController setToolbarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KINWebBrowserDelegate Protocol Implementation

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didBeginLoadingRequest:(NSURLRequest *)request {
    NSLog(@"Began Loading Request: %@", request.URL);
}

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingRequest:(NSURLRequest *)request {
    NSLog(@"Finished Loading Request : %@", request.URL);
}

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadRequest:(NSURLRequest *)request withError:(NSError *)error {
    NSLog(@"Failed To Load Request : %@ With Error: %@", request.URL, error);
}


#pragma mark - IBActions

- (IBAction)pushButtonPressed:(id)sender {
    KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowser];
    [webBrowser setDelegate:self];
    [self.navigationController pushViewController:webBrowser animated:YES];
    [webBrowser loadURLString:defaultAddress];
}

- (IBAction)presentButtonPressed:(id)sender {
    UINavigationController *webBrowserNavigationController = [KINWebBrowserViewController navigationControllerWithWebBrowser];
    KINWebBrowserViewController *webBrowser = [webBrowserNavigationController rootWebBrowserViewController];
    [webBrowser setDelegate:self];
    [self presentViewController:webBrowserNavigationController animated:YES completion:nil];

    [webBrowser loadURLString:defaultAddress];
}
@end
