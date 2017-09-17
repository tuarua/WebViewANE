// Copyright 2017 Tua Rua Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  Additional Terms
//  No part, or derivative of this Air Native Extensions's code is permitted
//  to be sold as the basis of a commercially packaged Air Native Extension which
//  undertakes the same purpose as this software. That is, a WebView for Windows,
//  OSX and/or iOS and/or Android.
//  All Rights Reserved. Tua Rua Ltd.

#import "FreMacros.h"
#import <Foundation/Foundation.h>
#import "WebViewANE_oc.h"
#ifdef OSX
#import "WebViewANE-Swift.h"
#else
#import <FreSwift/FreSwift-iOS-Swift.h>
#import "WebViewANE_FW-Swift.h"
#define FRE_OBJC_BRIDGE TRWV_FlashRuntimeExtensionsBridge // use unique prefix throughout to prevent clashes with other ANEs
@interface FRE_OBJC_BRIDGE : NSObject<FreSwiftBridgeProtocol>
@end
@implementation FRE_OBJC_BRIDGE {
}
FRE_OBJC_BRIDGE_FUNCS
@end
#endif

@implementation WEBVIEWANE_LIB
SWIFT_DECL(TRWV) // use unique prefix throughout to prevent clashes with other ANEs

CONTEXT_INIT(TRWV) {
    SWIFT_INITS(TRWV)
    
    /**************************************************************************/
    /******* MAKE SURE TO ADD FUNCTIONS HERE THE SAME AS SWIFT CONTROLLER *****/
    /**************************************************************************/
    static FRENamedFunction extensionFunctions[] =
    {
         MAP_FUNCTION(TRWV, reload)
        ,MAP_FUNCTION(TRWV, load)
        ,MAP_FUNCTION(TRWV, init)
        ,MAP_FUNCTION(TRWV, isSupported)
        ,MAP_FUNCTION(TRWV, setVisible)
        ,MAP_FUNCTION(TRWV, loadHTMLString)
        ,MAP_FUNCTION(TRWV, loadFileURL)
        ,MAP_FUNCTION(TRWV, onFullScreen)
        ,MAP_FUNCTION(TRWV, reloadFromOrigin)
        ,MAP_FUNCTION(TRWV, stopLoading)
        ,MAP_FUNCTION(TRWV, backForwardList)
        ,MAP_FUNCTION(TRWV, go)
        ,MAP_FUNCTION(TRWV, goBack)
        ,MAP_FUNCTION(TRWV, goForward)
        ,MAP_FUNCTION(TRWV, allowsMagnification)
        ,MAP_FUNCTION(TRWV, zoomIn)
        ,MAP_FUNCTION(TRWV, zoomOut)
        ,MAP_FUNCTION(TRWV, setViewPort)
        ,MAP_FUNCTION(TRWV, showDevTools)
        ,MAP_FUNCTION(TRWV, closeDevTools)
        ,MAP_FUNCTION(TRWV, callJavascriptFunction)
        ,MAP_FUNCTION(TRWV, evaluateJavaScript)
        ,MAP_FUNCTION(TRWV, injectScript)
        ,MAP_FUNCTION(TRWV, focus)
        ,MAP_FUNCTION(TRWV, print)
        ,MAP_FUNCTION(TRWV, capture)
        ,MAP_FUNCTION(TRWV, addTab)
        ,MAP_FUNCTION(TRWV, closeTab)
        ,MAP_FUNCTION(TRWV, setCurrentTab)
        ,MAP_FUNCTION(TRWV, getCurrentTab)
        ,MAP_FUNCTION(TRWV, getTabDetails)
        ,MAP_FUNCTION(TRWV, shutDown)
        ,MAP_FUNCTION(TRWV, clearCache)
        ,MAP_FUNCTION(TRWV, addEventListener)
        ,MAP_FUNCTION(TRWV, removeEventListener)
    };
    /**************************************************************************/
    /**************************************************************************/
    
    SET_FUNCTIONS

}

CONTEXT_FIN(TRWV) {
    //any clean up code here
}
EXTENSION_INIT(TRWV)
EXTENSION_FIN(TRWV)
@end
