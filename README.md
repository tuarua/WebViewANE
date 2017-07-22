
# WebViewANE 

WebView Adobe Air Native Extension for OSX 10.10+, Windows Desktop, iOS 9.0+ and Android21+.
This ANE provides access to a more modern webview from AIR.

Much time, skill and effort has gone into this. Help support the project   
[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=5UR2T52J633RC)

Sample client included   

[ASDocs Documentation](https://tuarua.github.io/asdocs/webviewane/)

## !! Version 0.0.26+
There is now a new dependency ANE.   
This is included in \native_extension\ane\CommonDependencies.ane.   
It must be included along with the WebView ANE in your projects.   
 It also must be created before the webView.   
````xml
<extensions>
    <extensionID>com.tuarua.WebViewANE</extensionID>
    <extensionID>com.tuarua.CommonDependencies</extensionID>
</extensions>
`````
````actionscript
private var commonDependenciesANE:CommonDependencies = new CommonDependencies();
private var webView:WebViewANE = new WebViewANE();
`````

## Windows
The Windows version utilises the [CefSharp WinForms](https://github.com/cefsharp/CefSharp) version of Chromium Embedded Framework.

##### Windows Installation - Important!

* Unzip the contents of cef_binaries.zip into the bin folder of your AIRSDK. 
* Copy the contents of the "cef_sharp_libs" folder into the bin folder of your AIRSDK. 

The location of this will vary depending on your IDE. These dlls and other cef files need to reside in the folder where adl.exe is run from.
* CEF was built with MS Visual Studio 2013. As such your machine (and user's machines) will need to have Microsoft Visual C++ 2013 Redistributable (x86) runtime installed.
http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x86.exe

* This ANE was built with MS Visual Studio 2015. As such your machine (and user's machines) will need to have Microsoft Visual C++ 2015 Redistributable (x86) runtime installed.
https://www.microsoft.com/en-us/download/details.aspx?id=48145

* This ANE also uses .NET 4.6 Framework. As such your machine (and user's machines) will need to have to have this installed.
https://www.microsoft.com/en-us/download/details.aspx?id=48130

* For release builds, the cef_binaries and cef_sharp_libs files need to be packaged in the same folder as your exe.  
It is highly recommended you package your app for release using an installer.  
Please see the win_installer folder for an example Inno Setup project which handles .NET 4.6 and MSVC2013 and MSV2015 dependencies.

* The Cef view and processes can only be attached once to your app. Therefore only one instance can be created and used.

## OSX

The OSX version utilises the native WKWebView.


## iOS

The iOS version utilises the native WKWebView.
The iOS version is written in Swift and uses a new way of writing ANEs for iOS. See this repo for more details https://github.com/tuarua/Swift-IOS-ANE

### Running on Simulator

The example project can be run on the Simulator from IntelliJ

### Running on Device !

The example project needs to be built and signed in the correct manner.
An AIR based packaging tool is provided at https://github.com/tuarua/AIR-iOS-Packager   
Here is a video [demonstrating how to use it](https://www.youtube.com/watch?v=H-G8WugNFQM&feature=youtu.be)   
[![youtube video](https://raw.githubusercontent.com/tuarua/WebViewANE/master/screenshots/ios-packaging.jpg)](https://www.youtube.com/watch?v=H-G8WugNFQM&feature=youtu.be)

## Android Important!
AIRSDK 26 is not supported. Please use AIRSDK 25 
The Android version utilises the native WebView. 


##

![alt tag](https://raw.githubusercontent.com/tuarua/WebViewANE/master/screenshots/screenshot1.jpg)



### References
* [https://developer.apple.com/reference/webkit/wkwebview]
* [https://github.com/cefsharp/CefSharp]
