### 0.0.33
- AND/iOS: added capture method

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
