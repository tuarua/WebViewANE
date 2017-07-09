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

#import "WebViewANE_oc.h"

#ifdef _WIN32
#elif __APPLE__
#include "TargetConditionals.h"
#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)

#include "FlashRuntimeExtensions.h"
#import "FlashRuntimeExtensionsBridge.h"
#import "WebViewANE_FW-Swift.h"

FlashRuntimeExtensionsBridge *freBridge; // this runs the native FRE calls and returns to Swift
FRESwiftBridge *swftBridge; // this is the bridge from Swift back to ObjectiveC

#elif TARGET_OS_MAC

#import <Foundation/Foundation.h>
#include "WebViewANE_oc.h"
#import "WebViewANE-Swift.h"
#include <Adobe AIR/Adobe AIR.h>

#else
#   error "Unknown Apple platform"
#endif
#endif

WebViewANE *swft; // our main Swift Controller
NSArray * funcArray;
#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

FRE_FUNCTION(callSwiftFunction) {
    NSString* fName = (__bridge NSString *)(functionData);
    return [swft callSwiftFunctionWithName:fName ctx:context argc:argc argv:argv];
}

void contextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet,
                        const FRENamedFunction **functionsToSet) {
    
#ifdef _WIN32
#elif __APPLE__
#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)
    freBridge = [[FlashRuntimeExtensionsBridge alloc] init];
    swftBridge = [[FRESwiftBridge alloc] init];
    [swftBridge setDelegateWithBridge:freBridge];
    
#elif TARGET_OS_MAC
    
#else
#   error "Unknown Apple platform"
#endif
#endif
    
    swft = [[WebViewANE alloc] init];
    [swft setFREContextWithCtx:ctx];
    
    funcArray = [swft getFunctions];
    /**************************************************************************/
    /********************* DO NO MODIFY ABOVE THIS LINE ***********************/
    /**************************************************************************/
    
    /******* MAKE SURE TO ADD FUNCTIONS HERE THE SAME AS SWIFT CONTROLLER *****/
    /**************************************************************************/
    static FRENamedFunction extensionFunctions[] =
    {
        { (const uint8_t*) "reload", (__bridge void *)@"reload", &callSwiftFunction }
        ,{ (const uint8_t*) "load", (__bridge void *)@"load", &callSwiftFunction }
        ,{ (const uint8_t*) "init", (__bridge void *)@"init", &callSwiftFunction }
        ,{ (const uint8_t*) "isSupported", (__bridge void *)@"isSupported", &callSwiftFunction }
        ,{ (const uint8_t*) "addToStage", (__bridge void *)@"addToStage", &callSwiftFunction }
        ,{ (const uint8_t*) "removeFromStage", (__bridge void *)@"removeFromStage", &callSwiftFunction }
        ,{ (const uint8_t*) "loadHTMLString", (__bridge void *)@"loadHTMLString", &callSwiftFunction }
        ,{ (const uint8_t*) "loadFileURL", (__bridge void *)@"loadFileURL", &callSwiftFunction }
        ,{ (const uint8_t*) "onFullScreen", (__bridge void *)@"onFullScreen", &callSwiftFunction }
        ,{ (const uint8_t*) "reloadFromOrigin", (__bridge void *)@"reloadFromOrigin", &callSwiftFunction }
        ,{ (const uint8_t*) "stopLoading", (__bridge void *)@"stopLoading", &callSwiftFunction }
        ,{ (const uint8_t*) "backForwardList", (__bridge void *)@"backForwardList", &callSwiftFunction }
        ,{ (const uint8_t*) "go", (__bridge void *)@"go", &callSwiftFunction }
        ,{ (const uint8_t*) "goBack", (__bridge void *)@"goBack", &callSwiftFunction }
        ,{ (const uint8_t*) "goForward", (__bridge void *)@"goForward", &callSwiftFunction }
        ,{ (const uint8_t*) "allowsMagnification", (__bridge void *)@"allowsMagnification", &callSwiftFunction }
        ,{ (const uint8_t*) "zoomIn", (__bridge void *)@"zoomIn", &callSwiftFunction }
        ,{ (const uint8_t*) "zoomOut", (__bridge void *)@"zoomOut", &callSwiftFunction }
        ,{ (const uint8_t*) "setPositionAndSize", (__bridge void *)@"setPositionAndSize", &callSwiftFunction }
        ,{ (const uint8_t*) "showDevTools", (__bridge void *)@"showDevTools", &callSwiftFunction }
        ,{ (const uint8_t*) "closeDevTools", (__bridge void *)@"closeDevTools", &callSwiftFunction }
        ,{ (const uint8_t*) "callJavascriptFunction", (__bridge void *)@"callJavascriptFunction", &callSwiftFunction }
        ,{ (const uint8_t*) "evaluateJavaScript", (__bridge void *)@"evaluateJavaScript", &callSwiftFunction }
        ,{ (const uint8_t*) "injectScript", (__bridge void *)@"injectScript", &callSwiftFunction }
        ,{ (const uint8_t*) "focus", (__bridge void *)@"focus", &callSwiftFunction }
        ,{ (const uint8_t*) "print", (__bridge void *)@"print", &callSwiftFunction }
        ,{ (const uint8_t*) "capture", (__bridge void *)@"capture", &callSwiftFunction }
        ,{ (const uint8_t*) "addTab", (__bridge void *)@"addTab", &callSwiftFunction }
        ,{ (const uint8_t*) "closeTab", (__bridge void *)@"closeTab", &callSwiftFunction }
        ,{ (const uint8_t*) "setCurrentTab", (__bridge void *)@"setCurrentTab", &callSwiftFunction }
        ,{ (const uint8_t*) "getCurrentTab", (__bridge void *)@"getCurrentTab", &callSwiftFunction }
        ,{ (const uint8_t*) "getTabDetails", (__bridge void *)@"getTabDetails", &callSwiftFunction }
        ,{ (const uint8_t*) "shutDown", (__bridge void *)@"shutDown", &callSwiftFunction }
        ,{ (const uint8_t*) "clearCache", (__bridge void *)@"clearCache", &callSwiftFunction }
    };
    /**************************************************************************/
    /**************************************************************************/
    
    
    *numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
    *functionsToSet = extensionFunctions;
    
}

void contextFinalizer(FREContext ctx) {
    return;
}

void TRWVExtInizer(void **extData, FREContextInitializer *ctxInitializer, FREContextFinalizer *ctxFinalizer) {
    *ctxInitializer = &contextInitializer;
    *ctxFinalizer = &contextFinalizer;
}

void TRWVExtFinizer(void *extData) {
    FREContext nullCTX;
    nullCTX = 0;
    contextFinalizer(nullCTX);
    return;
}




