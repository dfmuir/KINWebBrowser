KINWebBrowser
==========

KINWebBrowser is a web browser for your apps. It is compatible with iPhone and iPad devices running iOS 7.
Overview
------------------------
KINWebBrowser consists of a single component:

* **KINWebBrowserViewController** - a UIViewController that contains a full featured web browser.

*KINWebBrowserViewController must be contained in a UINavigationController.*

**Pushing to the navigation stack:**
```objc
KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowserViewController];
[self.navigationController pushViewController:webBrowser animated:YES];
[webBrowser loadURLString:@"http://www.example.com"];
```

**Presenting Modally:**
```objc
UINavigationController *webBrowserNavigationController = [KINWebBrowserViewController navigationControllerWithWebBrowser];
[self presentViewController:webBrowserNavigationController animated:YES completion:nil];

KINWebBrowserViewController *webBrowser = [webBrowserNavigationController rootWebBrowserViewController];
[webBrowser loadURLString:@"http://www.example.com"];
```
