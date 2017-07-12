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

FlashRuntimeExtensionsBridge *TRWV_freBridge; // this runs the native FRE calls and returns to Swift
FreSwiftBridge *TRWV_swftBridge; // this is the bridge from Swift back to ObjectiveC

#elif TARGET_OS_MAC

#import <Foundation/Foundation.h>
#include "WebViewANE_oc.h"
#import "WebViewANE-Swift.h"
#include <Adobe AIR/Adobe AIR.h>

#else
#   error "Unknown Apple platform"
#endif
#endif

WebViewANE *TRWV_swft; // our main Swift Controller
NSArray * TRWV_funcArray;

/****************************************************************************/
/****************** USE PREFIX TRWV_ TO PREVENT CLASHES  ********************/
/****************************************************************************/

#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (__bridge void *)(data), &TRWV_callSwiftFunction }

FRE_FUNCTION(TRWV_callSwiftFunction) {
    static NSString *const prefix = @"TRWV_";
    NSString* name = (__bridge NSString *)(functionData);
    NSString* fName = [NSString stringWithFormat:@"%@%@", prefix, name];
    return [TRWV_swft callSwiftFunctionWithName:fName ctx:context argc:argc argv:argv];
}

void TRWV_contextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet,
                        const FRENamedFunction **functionsToSet) {
    
#ifdef _WIN32
#elif __APPLE__
#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)
    TRWV_freBridge = [[FlashRuntimeExtensionsBridge alloc] init];
    TRWV_swftBridge = [[FreSwiftBridge alloc] init];
    [TRWV_swftBridge setDelegateWithBridge:TRWV_freBridge];
#endif
#endif
    
    TRWV_swft = [[WebViewANE alloc] init];
    [TRWV_swft setFREContextWithCtx:ctx];
    
    TRWV_funcArray = [TRWV_swft getFunctionsWithPrefix:@"TRWV_"];
    
    /**************************************************************************/
    /******* MAKE SURE TO ADD FUNCTIONS HERE THE SAME AS SWIFT CONTROLLER *****/
    /**************************************************************************/
    static FRENamedFunction extensionFunctions[] =
    {
         MAP_FUNCTION(reload, @"reload")
        ,MAP_FUNCTION(load, @"load")
        ,MAP_FUNCTION(init, @"init")
        ,MAP_FUNCTION(isSupported, @"isSupported")
        ,MAP_FUNCTION(addToStage, @"addToStage")
        ,MAP_FUNCTION(removeFromStage, @"removeFromStage")
        ,MAP_FUNCTION(loadHTMLString, @"loadHTMLString")
        ,MAP_FUNCTION(loadFileURL, @"loadFileURL")
        ,MAP_FUNCTION(onFullScreen, @"onFullScreen")
        ,MAP_FUNCTION(reloadFromOrigin, @"reloadFromOrigin")
        ,MAP_FUNCTION(stopLoading, @"stopLoading")
        ,MAP_FUNCTION(backForwardList, @"backForwardList")
        ,MAP_FUNCTION(go, @"go")
        ,MAP_FUNCTION(goBack, @"goBack")
        ,MAP_FUNCTION(goForward, @"goForward")
        ,MAP_FUNCTION(allowsMagnification, @"allowsMagnification")
        ,MAP_FUNCTION(zoomIn, @"zoomIn")
        ,MAP_FUNCTION(zoomOut, @"zoomOut")
        ,MAP_FUNCTION(setPositionAndSize, @"setPositionAndSize")
        ,MAP_FUNCTION(showDevTools, @"showDevTools")
        ,MAP_FUNCTION(closeDevTools, @"closeDevTools")
        ,MAP_FUNCTION(callJavascriptFunction, @"callJavascriptFunction")
        ,MAP_FUNCTION(evaluateJavaScript, @"evaluateJavaScript")
        ,MAP_FUNCTION(injectScript, @"injectScript")
        ,MAP_FUNCTION(focus, @"focus")
        ,MAP_FUNCTION(print, @"print")
        ,MAP_FUNCTION(capture, @"capture")
        ,MAP_FUNCTION(addTab, @"addTab")
        ,MAP_FUNCTION(closeTab, @"closeTab")
        ,MAP_FUNCTION(setCurrentTab, @"setCurrentTab")
        ,MAP_FUNCTION(getCurrentTab, @"getCurrentTab")
        ,MAP_FUNCTION(getTabDetails, @"getTabDetails")
        ,MAP_FUNCTION(shutDown, @"shutDown")
        ,MAP_FUNCTION(clearCache, @"clearCache")
    };
    /**************************************************************************/
    /**************************************************************************/
    
    *numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
    *functionsToSet = extensionFunctions;
    
}

void TRWV_contextFinalizer(FREContext ctx) {}

void TRWVExtInizer(void **extData, FREContextInitializer *ctxInitializer, FREContextFinalizer *ctxFinalizer) {
    *ctxInitializer = &TRWV_contextInitializer;
    *ctxFinalizer = &TRWV_contextFinalizer;
}

void TRWVExtFinizer(void *extData) {
    FREContext nullCTX = 0;
    TRWV_contextFinalizer(nullCTX);
    return;
}




