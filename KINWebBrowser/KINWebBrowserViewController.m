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

NSString *const KINWebBrowserShowsActionButton = @"com.kinwa.KINWebBrowser.showsActionButton";
NSString *const KINWebBrowserShowsProgressView = @"com.kinwa.KINWebBrowser.showsProgressView";
NSString *const KINWebBrowserRestoresNavigationBarState = @"com.kinwa.KINWebBrowser.restoresNavigationBarState";
NSString *const KINWebBrowserRestoresToolbarState = @"com.kinwa.KINWebBrowser.restoresToolbarState";



@implementation UINavigationController(KINWebBrowserWrapper)

- (KINWebBrowserViewController *)rootWebBrowserViewController {
    UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
    return (KINWebBrowserViewController *)rootViewController;
}

@end

@interface KINWebBrowserViewController ()

@property (nonatomic, strong) NSDictionary *options;

@property (nonatomic, assign) BOOL previousNavigationControllerToolbarHidden, previousNavigationControllerNavigationBarHidden;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, strong) UIBarButtonItem *backButton, *forwardButton, *refreshButton, *stopButton, *actionButton, *fixedSeparator, *flexibleSeparator;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, strong) NSURL *URL;

@end

@implementation KINWebBrowserViewController

static NSString *const safariActionTitle = @"Open in Safari";
static NSString *const chromeActionTitle = @"Open in Chrome";
static NSString *const copyActionTitle = @"Copy URL";
static NSString *const cancelActionTitle = @"Cancel";

#pragma mark - Static Initializers

+ (KINWebBrowserViewController *)webBrowser {
    KINWebBrowserViewController *webBrowserViewController = [KINWebBrowserViewController webBrowserWithOptions:nil];
    return webBrowserViewController;
}

+ (KINWebBrowserViewController *)webBrowserWithOptions:(NSDictionary *)options {
    KINWebBrowserViewController *webBrowserViewController = [[KINWebBrowserViewController alloc] initWithOptions:options];
    return webBrowserViewController;
}

+ (UINavigationController *)navigationControllerWithWebBrowser {
    KINWebBrowserViewController *webBrowserViewController = [[KINWebBrowserViewController alloc] init];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:webBrowserViewController action:@selector(doneButtonPressed:)];
    [webBrowserViewController.navigationItem setRightBarButtonItem:doneButton];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webBrowserViewController];
    return navigationController;
}

+ (UINavigationController *)navigationControllerWithWebBrowserWithOptions:(NSDictionary *)options {
    KINWebBrowserViewController *webBrowserViewController = [[KINWebBrowserViewController alloc] initWithOptions:options];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:webBrowserViewController action:@selector(doneButtonPressed:)];
    [webBrowserViewController.navigationItem setRightBarButtonItem:doneButton];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webBrowserViewController];
    return navigationController;
}

#pragma mark - Initializers

- (id)initWithOptions:(NSDictionary *)options {
    self = [super init];
    if(self) {
        self.options = options;
    }
    return self;
}


#pragma mark - Access Options

- (id)valueForOption:(NSString *)option {
    if(self.options && [self.options objectForKey:option]) {
        return [self.options objectForKey:option];
    }
    else {
        return [[self defaultOptions] objectForKey:option];
    }
}

- (NSDictionary *)defaultOptions {
    return
    @{
      KINWebBrowserShowsActionButton : @YES,
      KINWebBrowserShowsProgressView : @YES,
      KINWebBrowserRestoresNavigationBarState : @YES,
      KINWebBrowserRestoresToolbarState : @YES
      };
}


#pragma mark - Public Interface

- (void)loadURL:(NSURL *)URL {
    _URL = URL;
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];

    NSString *pageTitle = [URL absoluteString];
    self.title = pageTitle;
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
    [self.webView setMultipleTouchEnabled:YES];
    [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.webView setAutoresizesSubviews:YES];
    [self.webView setScalesPageToFit:YES];
    [self.webView.scrollView setAlwaysBounceVertical:YES];
    [self.view addSubview:self.webView];
    
    if([[self valueForOption:KINWebBrowserShowsProgressView] boolValue]) {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [self.progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-self.progressView.frame.size.height, self.view.frame.size.width, self.progressView.frame.size.height)];
        [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar addSubview:self.progressView];
    
    [self updateToolbarState];
    
    if(!self.webView.request && self.URL) {
        [self loadURL:self.URL];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if([[self valueForOption:KINWebBrowserRestoresNavigationBarState] boolValue]) {
        [self.navigationController setNavigationBarHidden:self.previousNavigationControllerNavigationBarHidden animated:animated];
    }
    
    if([[self valueForOption:KINWebBrowserRestoresToolbarState] boolValue]) {
        [self.navigationController setToolbarHidden:self.previousNavigationControllerToolbarHidden animated:animated];
    }
    
    [self.webView setDelegate:nil];
    [self.progressView removeFromSuperview];
}

#pragma mark - UIWebViewDelegate Protocol Implementation

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if(!self.loading) {
        [self didStartLoading];
    }
    [self updateToolbarState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = pageTitle;

    [self updateToolbarState];
    if(!self.webView.isLoading) {
        [self didFinishLoading];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadRequest:withError:)]) {
        [self.delegate webBrowser:self didFailToLoadRequest:self.webView.request withError:error];
    }
    
    if(!self.webView.isLoading) {
        [self didFinishLoading];
    }
}

#pragma mark - UIActionSheetDelegate Protocol Implementation

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:safariActionTitle]) {
        [self openInSafari];
    }
    else if([title isEqualToString:chromeActionTitle]) {
        [self openInChrome];
    }
    else if([title isEqualToString:copyActionTitle]) {
        [self copyURL];
    }
}


#pragma mark - Loading States

- (void)didStartLoading {
    self.loading = YES;
    [self progressViewStartLoading];
    [self updateToolbarState];
    if([self.delegate respondsToSelector:@selector(webBrowser:didBeginLoadingRequest:)]) {
        [self.delegate webBrowser:self didBeginLoadingRequest:self.webView.request];
    }
}

- (void)didFinishLoading {
    self.loading = NO;
    [self progressBarStopLoading];
    [self updateToolbarState];
    
    if([self.delegate respondsToSelector:@selector(webBrowser:didFinishLoadingRequest:)]) {
        [self.delegate webBrowser:self didFinishLoadingRequest:self.webView.request];
    }
}

#pragma mark - Toolbar State

- (void)updateToolbarState {
    [self.backButton setEnabled:self.webView.canGoBack];
    [self.forwardButton setEnabled:self.webView.canGoForward];
    
    if(!self.backButton) {
        [self setupToolbarItems];
    }
    
    NSArray *barButtonItems;
    if(!self.loading) {
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.refreshButton, self.flexibleSeparator];
    }
    else {
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.stopButton, self.flexibleSeparator];
    }
    
    if([[self valueForOption:KINWebBrowserShowsActionButton] boolValue]) {
        NSMutableArray *mutableBarButtonItems = [NSMutableArray arrayWithArray:barButtonItems];
        [mutableBarButtonItems addObject:self.actionButton];
        barButtonItems = [NSArray arrayWithArray:mutableBarButtonItems];
    }
    
    [self setToolbarItems:barButtonItems animated:YES];
}

- (void)setupToolbarItems {
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed:)];
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonPressed:)];
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    self.fixedSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.fixedSeparator.width = 50.0f;
    self.flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
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
    [self didStartLoading];
}

- (void)stopButtonPressed:(id)sender {
    [self.webView stopLoading];
    [self didFinishLoading];
}

- (void)actionButtonPressed:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        [actionSheet setDelegate:self];
        [actionSheet addButtonWithTitle:safariActionTitle];
        if([self canOpenGoogleChrome]) {
            [actionSheet addButtonWithTitle:chromeActionTitle];
        }
        [actionSheet addButtonWithTitle:copyActionTitle];
        [actionSheet addButtonWithTitle:cancelActionTitle];
        [actionSheet setCancelButtonIndex:[actionSheet numberOfButtons]-1];
        
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    });
}

#pragma mark - Fake Progress Bar Control

- (void)progressViewStartLoading {
    [self.progressView setProgress:0.0f animated:NO];
    [self.progressView setAlpha:1.0f];
    [self.progressView setHidden:NO];
    
    if(!self.progressTimer) {
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.f target:self selector:@selector(timerDidFire:) userInfo:nil repeats:YES];
    }
}

- (void)progressBarStopLoading {
    if(self.progressTimer) {
        [self.progressTimer invalidate];
    }
    
    if(self.progressView) {
        [self.progressView setProgress:1.0f animated:YES];
        [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.progressView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.progressView setHidden:YES];
        }];
    }
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

#pragma mark - Actions

- (void)openInSafari {
    NSURL *URL = self.webView.request.URL;
    [[UIApplication sharedApplication] openURL:URL];
}

- (void)openInChrome {
    NSURL *URL = self.webView.request.URL;
    
    NSString *chromeScheme = nil;
    if ([URL.scheme isEqualToString:@"http"]) {
        chromeScheme = @"googlechrome";
    }
    else if ([URL.scheme isEqualToString:@"https"]) {
        chromeScheme = @"googlechromes";
    }
    
    if (chromeScheme) {
        NSString *absoluteString = [URL absoluteString];
        NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
        NSString *urlNoScheme =
        [absoluteString substringFromIndex:rangeForScheme.location];
        NSString *chromeURLString =
        [chromeScheme stringByAppendingString:urlNoScheme];
        NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
        
        [[UIApplication sharedApplication] openURL:chromeURL];
    }
}

- (void)copyURL {
    NSURL *URL = self.webView.request.URL;
    NSString *URLString = [URL absoluteString];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:URLString];
}

#pragma mark - Determine If Actions Are Possible

- (BOOL)canOpenGoogleChrome {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]];
}

#pragma mark - Dismiss

- (void)dismissAnimated:(BOOL)animated {
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
