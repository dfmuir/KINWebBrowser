KINWebBrowser
==========

KINWebBrowser is a web browser module for your apps. Compatible with iPhone and iPad devices running iOS 7 & 8.

![KINWebBrowser Screenshots](http://i.imgur.com/z1jkWKG.png)

Features
------------------------
* iOS 7 & 8 support for iPhone and iPad
* Customizable UI
* Portrait and landscape orientation support
* Use with existing UINavigationController or present modally
* Load URL from `NSURL` or `NSString`
* Delegate protocol for status callbacks
* Action button to allow users to copy URL, share, or open in Safari & Google Chrome
* Supports subclassing
* Installation with [CocoaPods](http://cocoapods.org/)

Overview
------------------------
KINWebBrowser consists of a single component:

* `KINWebBrowserViewController` - a UIViewController that contains a full featured web browser.

*KINWebBrowserViewController must be contained in a UINavigationController.*

**Pushing to the navigation stack:**
```objective-c
KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowserViewController];
[self.navigationController pushViewController:webBrowser animated:YES];
[webBrowser loadURLString:@"http://www.example.com"];
```

**Presenting Modally:**
```objective-c
UINavigationController *webBrowserNavigationController = [KINWebBrowserViewController navigationControllerWithWebBrowser];
[self presentViewController:webBrowserNavigationController animated:YES completion:nil];

KINWebBrowserViewController *webBrowser = [webBrowserNavigationController rootWebBrowserViewController];
[webBrowser loadURLString:@"http://www.example.com"];
```

Installation With CocoaPods
------------------------

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the ["Getting Started" for more information](http://guides.cocoapods.org/using/getting-started.html).

#### Podfile

```ruby
platform :ios, '7.0'
pod 'KINWebBrowser', '~> 0.2.5'
```


Implementing `KINWebBrowserDelegate` Protocol
------------------------
`KINWebBrowserDelegate` is a set of `@optional` callback methods to inform the `delegate` of `NSURLRequest` status changes.

```- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didBeginLoadingRequest:(NSURLRequest *)request;```

```- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingRequest:(NSURLRequest *)request;```

```- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadRequest:(NSURLRequest *)request withError:(NSError *)error;```


Customizing the User Interface
------------------------
The user interface of `KINWebBrowserViewController` can be customized at initialization using an `NSDictionary` of boolean `NSNumber` values.

```objective-c
// Create an NSDictionary containing the keys and NSNumber booelan values 
NSDictionary *options = @{
                            KINWebBrowserShowsActionButton : @YES,
                            KINWebBrowserShowsProgressView : @NO
                        };
```
```objective-c
// Create a KINWebBrowserViewController instance with the specified options
[KINWebBrowserViewController webBrowserWithOptions:options];
```

```objective-c
/* Create a UINavigationController with the rootViewController containing
 an instance of KINWebBrowserViewController instance with the specified options */
 
[KINWebBrowserViewController navigationControllerWithWebBrowserWithOptions:options];
```

####The following values can be customized


| Key | Default Value | Description
|:----:|:----:|:--------------
|`KINWebBrowserShowsActionButton` | YES | Shows the action button. When enabled the action button launches a UIActivityViewController with the URL to copy to the clipboard, share, or launch Safari or Google Chrome. This displays in a UIPopoverController on iPad devices.
| `KINWebBrowserShowsProgressView` | YES | Shows a Safari-like progress view in the UINavigationBar that displays the loading progress of the request.
| `KINWebBrowserShowsPageTitleInNavigationBar` | YES | Once loading is complete, shows the <title> of the URL in the UINavigationBar
| `KINWebBrowserShowsPageURLInNavigationBar` | YES | During loading, shows the URL in the UINavigationBar
| `KINWebBrowserRestoresNavigationBarState` | YES | Restores the `navigationBarHidden` state from before KINWebBrowserViewController was pushed onto the navigation stack. Useful since KINWebBrowserViewController explicitly sets `navigationBarHidden` to `NO`. There is very little reason to set this value to `NO`
| `KINWebBrowserRestoresToolbarState` | YES | Restores the `toolbarBarHidden` state from before KINWebBrowserViewController was pushed onto the navigation stack. Useful since KINWebBrowserViewController explicitly sets `toolbarBarHidden` to `NO`.
