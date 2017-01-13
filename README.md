# WebViewANE

WebView Adobe Air Native Extension for OSX 10.10+ and Windows Desktop.
This ANE provides access to a more modern webview from AIR.

Sample client included

## Windows
The Windows version utilises the [CefSharp WPF](https://github.com/cefsharp/CefSharp) version of Chrome Embedded Framework.

##### Windows Installation - Important!

* Unzip the contents of cef_binaries.zip into the bin folder of your AIRSDK. The location of this will vary depending on your IDE or. These dlls and other cef files need to reside in the folder where adl.exe is run from
* For release builds, these files need to be packaged in the same folder as your exe
* The Cef view and processes can only be attached once to your app. Therefore only one instance can be created and used.
However, the view can be shown and hidden when not in use via the addToStage and removeFromStage methods
* CefSharp WPF uses OSR (Offscreen Rendering). Cef command line args have been optimised for this. However, this disables WebGL. If you want to use WebGL please set the following 
```actionscript
var settings:Settings = new Settings();
settings.cef.bestPerformance = false;
```

## OSX

The OSX version utilises the native WKWebView

## 

![alt tag](https://raw.githubusercontent.com/tuarua/WebViewANE/master/screenshots/screenshot1.jpg)


### To Do
* Allow 2 way Javascript Binding between AIR and the webView
* Implement loadFileURL method on Windows version
* Add additional CefSettings to settings.cef
* Add ability to set WKWebViewConfiguration of OSX version
* Asdocs


### Long Term To Do
* Investigate WebForms version of CefSharp for improved performance
* Windows Edge based WebView and CEF on OSX. Allow ability to select which one to be used, eg CEF or Native

### References
* [https://developer.apple.com/reference/webkit/wkwebview]
* [https://github.com/cefsharp/CefSharp]
