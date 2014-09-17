//
//  KINWebBrowserViewController.h
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

#import <UIKit/UIKit.h>

@class KINWebBrowserViewController;


#pragma mark - Initialization Options

// Show the action button on the UIToolbar to allow special actions on current page (launch in Safari, copy URL, etc.)
FOUNDATION_EXPORT NSString *const KINWebBrowserShowsActionButton;
// Show the UIProgressView along the bottom of the UINavigationBar to show loading progress
FOUNDATION_EXPORT NSString *const KINWebBrowserShowsProgressView;
// Show the page title in the navigation bar after the page has loaded
FOUNDATION_EXPORT NSString *const KINWebBrowserShowsPageTitleInNavigationBar;
// Show the page URL in the navigation bar while the page is loading
FOUNDATION_EXPORT NSString *const KINWebBrowserShowsPageURLInNavigationBar;
// Restore the hidden state of the UINavigationController navigationBar
FOUNDATION_EXPORT NSString *const KINWebBrowserRestoresNavigationBarState;
// Restore the hidden state of the UINavigationController toolbar
FOUNDATION_EXPORT NSString *const KINWebBrowserRestoresToolbarState;

/*
 
 UINavigationController+KINWebBrowserWrapper category enables access to casted KINWebBroswerViewController when set as rootViewController of UINavigationController
 
 */
@interface UINavigationController(KINWebBrowserWrapper)

// Returns rootViewController casted as KINWebBrowserViewController
- (KINWebBrowserViewController *)rootWebBrowserViewController;

@end



@protocol KINWebBrowserDelegate <NSObject>
@optional
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didBeginLoadingRequest:(NSURLRequest *)request;
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingRequest:(NSURLRequest *)request;
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadRequest:(NSURLRequest *)request withError:(NSError *)error;
@end


/*
 
 KINWebBrowserViewController is designed to be used inside of a UINavigationController.
 For convenience, two sets of static initializers are available.
 
 */
@interface KINWebBrowserViewController : UIViewController <UIWebViewDelegate>

#pragma mark - Public Properties

@property (nonatomic, weak) id <KINWebBrowserDelegate> delegate;

// The main and only UIWebView
@property (nonatomic, strong) UIWebView *webView;

// The main and only UIProgressView
@property (nonatomic, strong) UIProgressView *progressView;


#pragma mark - Static Initializers

// Initializes a basic KINWebBrowserViewController instance for push onto navigation stack
// Ideal for use with UINavigationController pushViewController:animated: or initWithRootViewController:
+ (KINWebBrowserViewController *)webBrowser;

// Initializes a KINWebBrowserViewController instance with custom options
// Ideal for use with UINavigationController pushViewController:animated: or initWithRootViewController:
+ (KINWebBrowserViewController *)webBrowserWithOptions:(NSDictionary *)options;


// Initializes a UINavigationController with a KINWebBrowserViewController for modal presentation
// Ideal for use with presentViewController:animated:
+ (UINavigationController *)navigationControllerWithWebBrowser;

// Initializes a UINavigationController with a KINWebBrowserViewController with custom options
// Ideal for use with presentViewController:animated:
+ (UINavigationController *)navigationControllerWithWebBrowserWithOptions:(NSDictionary *)options;

#pragma mark - Public Interface

// Loads a NSURL to webView
// Can be called any time after initialization
- (void)loadURL:(NSURL *)URL;

// Loads a URL as NSString to webView
// Can be called any time after initialization
- (void)loadURLString:(NSString *)URLString;

@end



