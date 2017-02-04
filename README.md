# WebViewANE 

WebView Adobe Air Native Extension for OSX 10.10+ and Windows Desktop.
This ANE provides access to a more modern webview from AIR.

Sample client included

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=5UR2T52J633RC)


## Windows
The Windows version utilises the [CefSharp WPF](https://github.com/cefsharp/CefSharp) version of Chrome Embedded Framework.

##### Windows Installation - Important!

* Unzip the contents of cef_binaries.zip into the bin folder of your AIRSDK. 
* Copy the contents of the "cef_sharp_libs" folder into the bin folder of your AIRSDK. 
The location of this will vary depending on your IDE or. These dlls and other cef files need to reside in the folder where adl.exe is run from.
* For release builds, these files need to be packaged in the same folder as your exe
* This ANE was built with MS Visual Studio 2015. As such your machine (and user's machines) will need to have Microsoft Visual C++ 2015 Redistributable (x86) runtime installed. Windows 10 machines will have this but perhaps not Windows 7.
https://www.microsoft.com/en-us/download/details.aspx?id=48145
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


### Long Term To Do
* Investigate WinForms version of CefSharp for improved performance
* Windows Edge based WebView and CEF on OSX. Allow ability to select which one to be used, eg CEF or Native

### References
* [https://developer.apple.com/reference/webkit/wkwebview]
* [https://github.com/cefsharp/CefSharp]
