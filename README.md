KINWebBrowser
==========

KINWebBrowser is a web browser module for your apps.

Powered by [WKWebView](https://developer.apple.com/library/IOs/documentation/WebKit/Reference/WKWebView_Ref/index.html) on iOS 8. Backwards compatible with iOS 7 using [UIWebView](https://developer.apple.com/library/ios/documentation/Uikit/reference/UIWebView_Class/index.html).

![KINWebBrowser Screenshots](http://i.imgur.com/z1jkWKG.png)

Features
------------------------
* iOS 7 & 8 support for iPhone and iPad devices
* Safari-like interface
* Animated progress bar
* Customizable UI including tint color
* Portrait and landscape orientation support
* Use with existing UINavigationController or present modally
* Delegate protocol for status callbacks
* Action button to allow users to copy URL, share, or open in Safari & Google Chrome
* Supports subclassing
* Installation with [CocoaPods](http://cocoapods.org/)

Overview
------------------------
KINWebBrowser consists of a single component:

**`KINWebBrowserViewController`** - a `UIViewController` that contains a full featured web browser.

*`KINWebBrowserViewController` must be contained in a UINavigationController.*

**Pushing to the navigation stack:**
```objective-c
KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowser];
[self.navigationController pushViewController:webBrowser animated:YES];
[webBrowser loadURLString:@"http://www.example.com"];
```

**Presenting Modally:**
```objective-c
UINavigationController *webBrowserNavigationController = [KINWebBrowserViewController navigationControllerWithWebBrowser];
[self presentViewController:webBrowserNavigationController animated:YES completion:nil];

KINWebBrowserViewController *webBrowser = [webBrowserNavigationController rootWebBrowser];
[webBrowser loadURLString:@"http://www.example.com"];
```

Installation
------------------------

#### Cocoapods
[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the ["Getting Started" for more information](http://guides.cocoapods.org/using/getting-started.html).

###### Podfile

```ruby
platform :ios, '7.0'
pod 'KINWebBrowser'
```

Dependencies
------------------------
These dependency projects should be also installed with KINWebBrowser. They are installed automatically when installing KINWebBrowser with CocoaPods.

* [TUSafariActivity](https://github.com/davbeck/TUSafariActivity) -  a UIActivity subclass that provides an "Open In Safari" action to a UIActivityViewController
* [ARChromeActivity](https://github.com/alextrob/ARChromeActivity) - a UIActivity subclass that provides an "Open In Google Chrome" action to a UIActivityViewController


Customizing the User Interface
------------------------

**Tint Color**

The tint color of the toolbars and toolbar items can be customized.

```
webBrowser.tintColor = [UIColor blueColor];
webBrowser.barTintColor = [UIColor blackColor];
```

**Title Bar Content** 

The URL can be shown in the `UINavigationBar` while loading. The title of the page can be shown when loading completes.
```
webBrowser.showsURLInNavigationBar = NO;
webBrowser.showsPageTitleInNavigationBar = YES;
```


Implementing `KINWebBrowserDelegate` Protocol
------------------------
`KINWebBrowserDelegate` is a set of `@optional` callback methods to inform the `delegate` of status changes.

```
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didStartLoadingURL:(NSURL *)URL;
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingURL:(NSURL *)URL;
- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL withError:(NSError *)error;
```
