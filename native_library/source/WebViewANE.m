/*@copyright The code is licensed under the[MIT
 License](http://opensource.org/licenses/MIT):
 
 Copyright © 2017 -  Tua Rua Ltd.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files(the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions :
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.*/

#import "WebViewANE_oc.h"

#ifdef _WIN32
#elif __APPLE__
#include "TargetConditionals.h"
#if (TARGET_IPHONE_SIMULATOR) || (TARGET_OS_IPHONE)

#include "FlashRuntimeExtensions.h"
#import "FlashRuntimeExtensionsBridge.h"
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


#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

// convert argv into a pointer array which can be passed to Swift
NSPointerArray * getFREargs(uint32_t argc, FREObject argv[]) {
    NSPointerArray * pa = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsOpaqueMemory];
    for (int i = 0; i < argc; ++i) {
        FREObject freObject;
        freObject = argv[i];
        [pa addPointer:freObject];
    }
    return pa;
}
    
FRE_FUNCTION (init) {
    [swft initWebViewWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (addToStage) {
    [swft addToStage];
    return NULL;
}

FRE_FUNCTION (removeFromStage) {
    [swft removeFromStage];
    return NULL;
}

FRE_FUNCTION (load) {
    [swft loadWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (loadHTMLString) {
    [swft loadHTMLStringWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (loadFileURL) {
    [swft loadFileURLWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (reload) {
    [swft reload];
    return NULL;
}

FRE_FUNCTION (reloadFromOrigin) {
    [swft reloadFromOrigin];
    return NULL;
}

FRE_FUNCTION (stopLoading) {
    [swft stopLoading];
    return NULL;
}

FRE_FUNCTION (goBack) {
    [swft goBack];
    return NULL;
}

FRE_FUNCTION (goForward) {
    [swft goForward];
    return NULL;
}

FRE_FUNCTION (backForwardList) {
    return [swft backForwardList];
}

FRE_FUNCTION (go) {
    [swft goWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (isSupported) {
    return [swft isSupported];
}

FRE_FUNCTION (allowsMagnification) {
    return [swft allowsMagnification];
}

FRE_FUNCTION (getMagnification) {
    return [swft getMagnification];
}

FRE_FUNCTION (setMagnification) {
    [swft setMagnificationWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (evaluateJavaScript) {
    [swft evaluateJavaScriptWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION (setPositionAndSize) {
    [swft setPositionAndSizeWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION(onFullScreen) {
    [swft onFullScreenWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION(showDevTools) {
    return NULL;
}

FRE_FUNCTION(closeDevTools) {
    return NULL;
}

FRE_FUNCTION(callJavascriptFunction) {
    [swft callJavascriptFunctionWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION(setBackgroundColor) {
    [swft setBackgroundColorWithArgv:getFREargs(argc, argv)];
    return NULL;
}

FRE_FUNCTION(shutDown) {
    return NULL;
}

FRE_FUNCTION(injectScript) {
    [swft injectScriptWithArgv:getFREargs(argc, argv)];
    return NULL;
}

void contextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet) {

    static FRENamedFunction extensionFunctions[] = {
        {(const uint8_t *) "init", NULL, &init}
        ,{(const uint8_t *) "isSupported", NULL, &isSupported}
        ,{(const uint8_t *) "addToStage", NULL, &addToStage}
        ,{(const uint8_t *) "removeFromStage", NULL, &removeFromStage}
        ,{(const uint8_t *) "load", NULL, &load}
        ,{(const uint8_t *) "loadHTMLString", NULL, &loadHTMLString}
        ,{(const uint8_t *) "loadFileURL", NULL, &loadFileURL}
        ,{(const uint8_t *) "reload", NULL, &reload}
        ,{(const uint8_t *) "onFullScreen", NULL, &onFullScreen}
        ,{(const uint8_t *) "reloadFromOrigin", NULL, &reloadFromOrigin}
        ,{(const uint8_t *) "stopLoading", NULL, &stopLoading}
        ,{(const uint8_t *) "backForwardList", NULL, &backForwardList}
        ,{(const uint8_t *) "go", NULL, &go}
        ,{(const uint8_t *) "goBack", NULL, &goBack}
        ,{(const uint8_t *) "goForward", NULL, &goForward}
        ,{(const uint8_t *) "allowsMagnification", NULL, &allowsMagnification}
        ,{(const uint8_t *) "getMagnification", NULL, &getMagnification}
        ,{(const uint8_t *) "setMagnification", NULL, &setMagnification}
        ,{(const uint8_t *) "setPositionAndSize", NULL, &setPositionAndSize}
        ,{(const uint8_t *) "showDevTools", NULL, &showDevTools }
        ,{(const uint8_t *) "closeDevTools", NULL, &closeDevTools }
        ,{(const uint8_t *) "onFullScreen", NULL, &onFullScreen }
        ,{(const uint8_t *) "callJavascriptFunction", NULL, &callJavascriptFunction }
        ,{(const uint8_t *) "evaluateJavaScript", NULL, &evaluateJavaScript }
        ,{(const uint8_t *) "setBackgroundColor", NULL, &setBackgroundColor }
        ,{(const uint8_t *) "shutDown", NULL, &shutDown }
        ,{ (const uint8_t *) "injectScript", NULL, &injectScript }
        

    };
    *numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
    *functionsToSet = extensionFunctions;
    
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




