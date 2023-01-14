### 2.28.0
- iOS/macOS: Updated to FreSwift 5.7.2
- AND: Updated to FreKotlin 1.72.1

### 2.27.0
- WIN: Updated to CefSharp 106.0.29

### 2.26.0
- AND: Add `AndroidSettings.scrollBarsEnabled`

### 2.25.0
- WIN: Updated to CefSharp 98.1.21

### 2.24.0
- WIN: Updated to CefSharp 96.0.18
- iOS/macOS: Updated to FreSwift 5.5.2

### 2.23.0
- WIN: Updated to CefSharp 95.7.14
- iOS/macOS: Updated to FreSwift 5.5.1
- macOS: Support Apple M1

### 2.22.0
- WIN/macOS: add `settings.disableFileDialog`

### 2.21.0
- WIN: Updated to CefSharp 94.1.11
- iOS/macOS: Updated to FreSwift 5.5.0

### 2.20.0
- WIN: Updated to CefSharp 93.1.11
- iOS/macOS: Updated to FreSwift 5.2.0

### 2.19.0
- WIN: Updated to CefSharp 90.6.50
- WIN: Opened popup windows are positioned relative to parent window

### 2.18.0
- WIN: remove `settings.WebEngine`
- WIN: Updated to CefSharp 89.0.170
- WIN: updated Json.NET to 13.0.1
- WIN: remove Edge WebView1

### 2.17.0
- macOS: Add handling for cut, copy, paste to WKWebView Issue #276

### 2.15.0
- WIN: fix BUG Windows 7 Issue #274

### 2.14.0
- WIN: Updated to CefSharp 86.0.241
- iOS/macOS: Updated to FreSwift 5.1.0
- macOS: `webView.print()` and `webView.printToPdf()` are now available on macOS 11.0+
- macOS: Added `WebkitSettings.limitsNavigationsToAppBoundDomains`
- AND: Updated to FreKotlin 1.42.0

### 2.13.0
- WIN/macOS: Support windowFeatures on `window.open()` Issue #264
- WIN: Improve ScaleFactor detection Issue #263
- AND: Updated to FreKotlin 1.41.0
- iOS/macOS: Updated to FreSwift 5.0.0
- WIN: Updated to FreSharp 2.5.0
- WIN: Deprecate Modern WebView1 (Edge) support

### 2.12.0
- AND: Updated to FreKotlin 1.40.0
- iOS: Updated to FreSwift 4.5.0

### 2.11.0
- WIN: Updated to CefSharp 83.4.200
- WIN: `CefSettings.cachePath` must now be an absolute path
- macOS: fix BUG window.opener Issue #253
- macOS: fix .visible and tabs Issue #199
- AND: BUG fix - select tag Issue #252

### 2.10.0
- OSX/iOS: Updated to FreSwift 4.4.0
- AND: Support File input tag (v21 and above)

### 2.9.0
- API changes. Now use `var webView = WebView.shared();`
- AND: Updated to FreKotlin 1.9.5
- AND: Updated to Gson 2.8.6
- OSX/iOS: Updated to FreSwift 4.3.0
- WIN: Updated to FreSharp 2.4.0
- WIN: Updated to CefSharp 79.1.360

### 2.8.0
- WIN: Updated to Windows Toolkit 5.1.1 for Modern WebView (Edge)
- WIN: Updated to CefSharp 75.1.142

### 2.7.0
- WIN: Updated to CefSharp 75.1.141

### 2.6.0
- AND: Updated to FreKotlin 1.8.0
- Updated to AIR 33 ARM 64bit

### 2.5.1
- macOS/iOS: `baseUrl` is null for `loadHTMLString` Issue #214

### 2.5.0
- WIN: C# and CefSharp binaries are now packaged inside the ANE. All of these need to be deleted from your AIRSDK 
- WIN: FreSharp.ane is now a required dependency for Windows. 

### 2.4.0
- WIN: updated Json.NET to 12.0.2
- WIN: Updated to CefSharp 73.1.130
- WIN: CefSharp now supports estimatedProgress

### 2.3.1
- AND: Fix capture bug Issue #207

### 2.3.0
- AND: Updated to FreKotlin 1.7.0
- Upgraded to AIR 32.0.0.116
- OSX/iOS: Updated to FreSwift 3.1.0
- WIN: Updated to FreSharp 2.2.0

### 2.2.1
- WIN Edge: Add Ability to add/modify custom Request Headers Issue #200

### 2.2.0
- AND/iOS/WIN/OSX: [BREAKING CHANGE] all urls are now passed as `URLRequest`
- WIN/OSX/iOS/Android: Add Ability to add/modify custom Request Headers Issue #200
- OSX: Fix WebView becomes visible after calling addTab() on macOS. Issue #199
- WIN: Updated to CefSharp 71.0.2

### 2.1.1
- OSX: Fix modifier keys not emitting keyboard events Issue #196
- WIN: Added Windows 7 touch support Issue #194

### 2.1.0
- AND: Updated to FreKotlin 1.6.0
- Upgraded to AIR 32
- OSX/iOS: Updated to FreSwift 3.0.0
- WIN: Updated to FreSharp 2.1.0
- WIN: Updated to Windows Toolkit 5.0.1 for Modern WebView (Edge)

### 2.0.1
- iOS: Support AIR 32

### 2.0.0
- AND/iOS/WIN/OSX: remove `webView.isSupported`, is always true
- WIN: Updated to Windows Toolkit 5.0.0 for Modern WebView (Edge)
- WIN: Updated to CefSharp 69.0.0
- WIN: useHiDPI param removed from `init()`, added to `Settings.useHiDPI`
- WIN: Added `Settings.useTransparentBackground`

### 1.9.2
- WIN: Rendering problem on some systems Issue #185
- WIN: Added `CefSettings.locale` Issue #185
- WIN: Revert Issue #168 related to Issue #185

### 1.9.1
- AND/iOS/WIN/OSX: Added `deleteCookies()` method

### 1.9.0
- WIN: Updated to FreSharp 2.0.0
- WIN: Updated to Windows Toolkit 4.0.0 for Modern WebView (Edge)
- WIN: Added local file support for Modern WebView (Edge)
- WIN: Added JS support for Modern WebView (Edge)
- WIN: Added Whitelist Blacklist support for Modern WebView (Edge)
- WIN: Updated to CefSharp 67.0.0
- WIN: Added `CefSettings.acceptLanguageList` Issue #177 
- AND: Updated to FreKotlin 1.5.0
- Upgraded to AIR 31

### 1.8.3
- WIN: Add popup.Behaviour.REPLACE Issue #170, Issue #171

### 1.8.1
- WIN: add BackgroundColor to HwndSource Issue #168

### 1.8.0
- OSX/iOS: Updated to FreSwift 2.5.0
- AND: Updated to FreKotlin 1.4.0
- WIN: Updated to FreSharp 1.7.0
- WIN: Updated to CefSharp 65.0.0

### 1.7.0
- WIN: Updated to CefSharp 65.0.0 pre-rel
- WIN: UTF-8 bug Issue #155
- WIN: Remove MSVC2013 as a dependency
- WIN: Updated to FreSharp 1.6.0
- WIN: Added basic support for Modern WebView (Edge)
- WIN/OSX: Add Flex and pure AS3 minimum examples

### 1.6.5
- Updated to AIR 30
- AND: Updated to FreKotlin 1.3.0
- OSX: WKWebview download implementation Issue #148
- iOS: Added WebkitSettings.custom to allow setting custom preferences KVPs Issue #150
- WIN: CefSettings.downloadPath is now Settings.downloadPath
- WIN: CefSettings.enableDownloads is now Settings.enableDownloads
- WIN: CefSettings.contextMenu is now Settings.contextMenu
- WIN: refactor C# structure to prepare for Modern WebView Edge based control

### 1.6.1
- AND/iOS/WIN/OSX: Make urlWhiteList and urlBlackList case insensitive Issue #142
- WIN: Added CefSettings.userDataPath Issue #141

### 1.6.0
- WIN: Updated to FreSharp 1.5.0
- WIN: Added CefSettings.downloadPath
- AND/iOS/WIN/OSX: BREAKING CHANGE!! - capture() now uses closure for result Issue #134
- AND/iOS/WIN/OSX: Combined mobile and desktop to single ANE
- AND/iOS/WIN/OSX: Moved ANE to releases
- OSX/iOS: Combined Xcode projects

### 1.5.0
- OSX/iOS: Updated to FreSwift 2.4.0
- WIN: Updated to CefSharp 63.0.3

### 1.4.0
- Updated to AIR 29
- OSX/iOS: Updated to FreSwift 2.3.0
- AND: Updated to FreKotlin 1.2.0
- WIN: Fix webView.tabDetails getter Issue #128

### 1.3.2
- WIN/OSX/iOS/AND: Handle different String formats for loadFileUrl Issue #124
- WIN: UTF-8 support for javascript functions Issue #125
- WIN: Remove Geolocation API

### 1.3.1
- WIN: Updated to CefSharp 63.0.1

### 1.3.0
- WIN: Updated to CefSharp 63 Issue #53 Issue #120
- WIN: BREAKING CHANGE!! JS binding now required as async - see updated jsTest.html
- WIN: Correctly handle Encoding Issue #118
- WIN: Updated to FreSharp 1.4.0
- AND: Handle back button Issue #116
- AND: Updated to FreKotlin 1.1.0
- OSX/iOS: Swift linting

### 1.2.0
- AND/OSX/iOS: dispose not working correctly Issue #114
- OSX/iOS: Updated to FreSwift 2.2.0

### 1.1.0
- Color now passed to init in ARGB format eg 0xFF333666
- OSX: Updated to FreSwift 2.1.0
- WIN: Updated to FreSharp 1.3.0
- AND: Updated to FreKotlin 1.0.0
- OSX: Add support for file input. Issue #111
- WIN: added capture method support for Win 64bit
- Upgrade to AIR SDK 28

### 1.0.0
- OSX/iOS: Updated to FreSwift 2.0.0
- OSX/iOS: Updated to Xcode 9.1
- WIN: printToPdf() method added

### 0.0.36
- OSX/iOS: Updated to FreSwift 1.3.0
- OSX/iOS: Updated to Xcode 8.3.3

### 0.0.35
- Updated FreKotlin
- WIN: support HiDPI
- AND: minor updates

### 0.0.34
- AND/iOS: allow pinch zoom to be enabled/disabled Issue #92
- iOS: Add instructions for submitting to AppStore Issue #94

### 0.0.33
- AND/iOS: added capture method Issue #88

### 0.0.32
- AND/iOS/WIN/OSX: Refactor
- Updated FreSwift
- Updated FreKotlin

### 0.0.31
- AND/iOS Refactor
- OSX/iOS Compiled FreSwift as external framework
- AND/iOS Remove Swift dependencies from Git - now included with release tags

### 0.0.30
- WIN: add KeyboardEvent support. Issue #66
- WIN: update to FreSharp 1.1.0. Issue #76
- AND: Rewrite in Kotlin.
- AND: Upgrade to AIR 26.
- AND/iOS/WIN/OSX: remove deprecated methods.
- AND/iOS/WIN/OSX: improve error capture.
- WIN: updated Json.NET to 10.0.3

### 0.0.29
- iOS: Upgrade to AIR 27 Beta. Removes need for external signing tool to run on device.

### 0.0.28
- WIN: 64bit added

### 0.0.27
- WIN/OSX: added ON_POPUP_BLOCKED event Issue #45

### 0.0.26
- OSX: Add dev tools support
- OSX: Deprecate onFullScreen() method, handled internally
- OSX: Deprecate ON_ESC_KEY event, handled internally
- AND/iOS/WIN/OSX: added cacheEnabled to settings Issue #62
- AND/iOS/WIN/OSX: added clearCache() method Issue #62
- OSX: Added CommonDependencies ANE requirement
- AND: fix BUG Issue #63

### 0.0.25
- WIN/OSX: Added multi-tab support
- AND/iOS/WIN/OSX: BREAKING CHANGE!! - init() now takes the following params: 
init(stage:Stage, viewPort:Rectangle, initialUrl:String, settings:Settings, scaleFactor:Number, backgroundColor:uint, backgroundAlpha:Number)
- AND/iOS/WIN/OSX: BREAKING CHANGE!! - onPropertyChange now returns event.params as {propertyName, tab, value}
- AND/iOS/WIN/OSX: BREAKING CHANGE!! - onUrlBlocked now returns event.params as {url, tab}
- AND/iOS/WIN/OSX: deprecate setPositionAndSize() - use viewPort setter instead
- AND/iOS/WIN/OSX: deprecate addToStage() - use visible setter instead
- AND/iOS/WIN/OSX: deprecate removeFromStage() - use visible setter instead
- AND/iOS/WIN/OSX: deprecate setBackgroundColor() - use params in init instead
- AND/iOS/WIN/OSX: deprecate shutDown() - not needed
- AND/WIN/OSX: deprecate getMagnification() due to inconsistent behaviour
- AND/WIN/OSX: deprecate setMagnification() due to inconsistent behaviour
- AND/WIN/OSX: add zoomIn() and zoomOut() methods
- AND/iOS/WIN/OSX: deprecate url, title, isLoading, canGoBack, canGoForward, estimatedProgress getters - call tabDetails getter instead
- OSX: fix BUG in example when minimising maximising
- OSX: add web page title to popup window
- iOS: add property settings.webkit.bounces true/false
- iOS/OSX: fix BUG in go() method
- AND/iOS/OSX: add whitelist to settings
- AND/iOS/WIN/OSX: add blacklist to settings
- AND: add WebViewEvent.ON_FAIL events
- WIN/OSX: update example to AIR SDK 26
- iOS/OSX: refactor
- WIN/OSX: Add check that AIR window can be referenced before attaching the native view

### 0.0.24
- WIN: Allow right click context menu to be disabled Issue #52
- WIN: BUG fix - capture method Issue #54

### 0.0.23
- WIN: add whitelist to settings
- WIN: upgrade to using FreSharp 1.0.7

### 0.0.22
- WIN: upgrade to using FreSharp 1.0.6 Issue #42
- iOS/OSX: upgrade to latest FRESwift

### 0.0.21
- WIN/OSX: Handle popups via settings Issue #40
- AND/iOS/WIN/OSX: move mobile ANE to fix Issue #39

### 0.0.20
- WIN: upgrade to CEF 57 Issue #34
- WIN: added geoLocation request handling Issue #32
- WIN: upgrade to Json.NET 10.0.2 Issue #35
- WIN: added print method Issue #36
- WIN: added capture method Issue #3
- WIN: upgrade to using FreSharp 1.0.1 Issue #37

### 0.0.19
- WIN: add new method focus() Issue #31
- AND/iOS: add default platform Issue #29
- AND: add onPermissionRequest, onGeolocation where AIR < 24 Issue #28

### 0.0.18
- WIN/OSX: Fix Issue #26 with setPositionAndSize
- WIN: Implement Issue #27 allow downloads to be enabled disabled

### 0.0.17
- iOS/OSX: added getFunctions(). Functions are defined here. Removes need to edit -Swift.h bridging header
- iOS/OSX:  Update to Swift 3.1 + Xcode 8.3

### 0.0.16
- Android: Add Android version
- iOS: Allow transparent background

### 0.0.15
- iOS: Add iOS version

### 0.0.14
- OSX: Fix Issue #22

### 0.0.13
- WIN: Changed to use CefSharp.WinForms. Improved performance Issue #17
- WIN: Added support for touch devices. Issue #19
- WIN/OSX: Added ON_ESC_KEY event. Issue #20

### 0.0.12
- WIN: Upgraded CEF to 55.0.0 Issue #16
- WIN: Add browserSubprocessPath to settings.cef #15
- WIN/OSX: allow custom userAgent to be set Issue #13
- WIN/OSX: add injectScript() method Issue #12

### 0.0.11
- WIN: Ability to set Background color of WPF control Issue #9
- WIN: Add statusMessage to onPropertyChange Issue #10
- WIN: added shutDown() method to fix Issue #11

### 0.0.10
- OSX: Enable Flash Player by default #7
- WIN: Chrome Developer Tools #5
- WIN/OSX: JS Binding #4
- WIN: loadFileURL method added

### 0.0.9
- OSX: Further Fix Issue#2
- WIN: Moved CefSharpLib.dll to own folder

### 0.0.8
- OSX: Fix Issue#2

### 0.0.7
- WIN: Fix Issue#1
- WIN/OSX: Added setPositionAndSize method

### 0.0.6
- WIN: added Chromium Embedded Framework version
- Utilised observer model better
- ON_PROPERTY_CHANGE event added
- Removed unneeded events
- updated example

### 0.0.5
- back forward methods added

### 0.0.4
- magnification methods added

### 0.0.3
- loadHTMLString, loadFileUrl added
- improved example

### 0.0.2  
- More functionality added

### 0.0.1  
- initial OSX
