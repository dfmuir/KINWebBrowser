//
//  KINWebBrowserViewController.m
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


#import "KINWebBrowserViewController.h"

@implementation UINavigationController(KINWebBrowserWrapper)

- (KINWebBrowserViewController *)rootWebBrowserViewController {
    UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
    return (KINWebBrowserViewController *)rootViewController;
}

@end

@interface KINWebBrowserViewController ()

@property (nonatomic, assign) BOOL previousNavigationControllerToolbarHidden, previousNavigationControllerNavigationBarHidden;
@property (nonatomic, strong) UIBarButtonItem *backButton, *forwardButton, *refreshButton, *actionButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, strong) NSURL *URL;

@end

@implementation KINWebBrowserViewController

#pragma mark - Static Initializers

+ (KINWebBrowserViewController *)webBrowserViewController {
    KINWebBrowserViewController *webBrowserViewController = [[KINWebBrowserViewController alloc] init];
    return webBrowserViewController;
}

+ (UINavigationController *)navigationControllerWithRootWebBrowserViewController {
    KINWebBrowserViewController *webBrowserViewController = [[KINWebBrowserViewController alloc] init];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:webBrowserViewController action:@selector(doneButtonPressed:)];
    [webBrowserViewController.navigationItem setRightBarButtonItem:doneButton];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webBrowserViewController];
    return navigationController;
}

#pragma mark - Public Interface

- (void)loadURL:(NSURL *)URL {
    _URL = URL;
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    [self didStartLoading];
}

- (void)loadURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadURL:URL];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.previousNavigationControllerToolbarHidden = self.navigationController.toolbarHidden;
    self.previousNavigationControllerNavigationBarHidden = self.navigationController.navigationBarHidden;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];

    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.webView setDelegate:self];
    [self.webView setOpaque:NO];
    [self.webView setMultipleTouchEnabled:YES];
    [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.webView setAutoresizesSubviews:YES];
    [self.webView setScalesPageToFit:YES];
    [self.webView.scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [self.webView.scrollView setAlwaysBounceVertical:YES];
    [self.view addSubview:self.webView];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self.progressView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.progressView.frame.size.height)];
    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.progressView];
    
    [self loadURL:self.URL];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonPressed:)];
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    
    UIBarButtonItem *fixedSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSeparator.width = 50.0f;
    
    UIBarButtonItem *flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *barButtonItems = @[self.refreshButton, flexibleSeparator, self.backButton, fixedSeparator, self.forwardButton, flexibleSeparator, self.actionButton];
    [self setToolbarItems:barButtonItems animated:NO];
    
    [self updateToolbarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - UIWebViewDelegate Protocol Implementation

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self updateToolbarState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateToolbarState];
    if(!self.webView.isLoading) {
        [self didFinishLoading];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(!self.webView.isLoading) {
        [self didFinishLoading];
    }
}

#pragma mark - Loading States

- (void)didStartLoading {
    [self progressViewStartLoading];
    [self updateToolbarState];
}

- (void)didFinishLoading {
    [self progressBarStopLoading];
    [self updateToolbarState];
}

#pragma mark - Toolbar State

- (void)updateToolbarState {
    [self.backButton setEnabled:self.webView.canGoBack];
    [self.forwardButton setEnabled:self.webView.canGoForward];
}

#pragma mark - Done Button Action

- (void)doneButtonPressed:(id)sender {
    [self dismissAnimated:YES];
}

#pragma mark - UIBarButtonItem Target Action Methods

- (void)backButtonPressed:(id)sender {
    [self.webView goBack];
    [self updateToolbarState];
}

- (void)forwardButtonPressed:(id)sender {
    [self.webView goForward];
    [self updateToolbarState];
}

- (void)refreshButtonPressed:(id)sender {
    [self.webView stopLoading];
    [self.webView reload];
}

- (void)actionButtonPressed:(id)sender {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.self.webView.request.URL] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Fake Progress Bar Control

- (void)progressViewStartLoading {
    if(!self.progressTimer) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setHidden:NO];
        [self.progressView setProgress:0 animated:NO];
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.f target:self selector:@selector(timerDidFire:) userInfo:nil repeats:YES];
    }
}

- (void)progressBarStopLoading {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    
    [self.progressView setProgress:1.0f animated:YES];
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.progressView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.progressView setHidden:YES];
    }];
}

- (void)timerDidFire:(id)sender {
    CGFloat increment = 0.005/(self.progressView.progress + 0.2);
    if([self.webView isLoading]) {
        CGFloat progress = (self.progressView.progress < 0.75f) ? self.progressView.progress + increment : self.progressView.progress + 0.0005;
        if(self.progressView.progress < 0.95) {
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

#pragma mark - Dismiss

- (void)dismissAnimated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:self.previousNavigationControllerNavigationBarHidden animated:animated];
    [self.navigationController setToolbarHidden:self.previousNavigationControllerToolbarHidden animated:animated];
    [self.navigationController dismissViewControllerAnimated:animated completion:nil];
}

#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate {
    return YES;
}


@end
