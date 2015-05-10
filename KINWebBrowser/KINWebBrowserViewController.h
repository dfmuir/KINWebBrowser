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
#import <WebKit/WebKit.h>

@class KINWebBrowserViewController;

/*
 
 UINavigationController+KINWebBrowserWrapper category enables access to casted KINWebBroswerViewController when set as rootViewController of UINavigationController
 
 */
@interface UINavigationController(KINWebBrowser)

// Returns rootViewController casted as KINWebBrowserViewController
- (KINWebBrowserViewController *)rootWebBrowser;

@end



@protocol KINWebBrowserDelegate <NSObject>
@optional
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didStartLoadingURL:(NSURL *)URL;
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingURL:(NSURL *)URL;
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL error:(NSError *)error;
- (void)webBrowserViewControllerWillDismiss:(KINWebBrowserViewController*)viewController;
@end


/*
 
 KINWebBrowserViewController is designed to be used inside of a UINavigationController.
 For convenience, two sets of static initializers are available.
 
 */
@interface KINWebBrowserViewController : UIViewController <WKNavigationDelegate, UIWebViewDelegate>

#pragma mark - Public Properties

@property (nonatomic, weak) id <KINWebBrowserDelegate> delegate;

// The main and only UIProgressView
@property (nonatomic, strong) UIProgressView *progressView;

// The web views
// Depending on the version of iOS, one of these will be set
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIWebView *uiWebView;

- (id)initWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

#pragma mark - Static Initializers

/*
 Initialize a basic KINWebBrowserViewController instance for push onto navigation stack
 
 Ideal for use with UINavigationController pushViewController:animated: or initWithRootViewController:
 
 Optionally specify KINWebBrowser options or WKWebConfiguration
 */

+ (KINWebBrowserViewController *)webBrowser;
+ (KINWebBrowserViewController *)webBrowserWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

/*
 Initialize a UINavigationController with a KINWebBrowserViewController for modal presentation.
 
 Ideal for use with presentViewController:animated:
 
 Optionally specify KINWebBrowser options or WKWebConfiguration
 */

+ (UINavigationController *)navigationControllerWithWebBrowser;
+ (UINavigationController *)navigationControllerWithWebBrowserWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);



@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, assign) BOOL actionButtonHidden;
@property (nonatomic, assign) BOOL showsURLInNavigationBar;
@property (nonatomic, assign) BOOL showsPageTitleInNavigationBar;

//Allow for custom activities in the browser by populating this optional array
@property (nonatomic, strong) NSArray *customActivityItems;

#pragma mark - Public Interface

// Load a NSURL to webView
// Can be called any time after initialization
- (void)loadURL:(NSURL *)URL;

// Loads a URL as NSString to webView
// Can be called any time after initialization
- (void)loadURLString:(NSString *)URLString;

@end

